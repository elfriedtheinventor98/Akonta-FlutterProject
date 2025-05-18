import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class ComptabilitePage extends StatefulWidget {
  const ComptabilitePage({Key? key}) : super(key: key);

  @override
  _ComptabilitePageState createState() => _ComptabilitePageState();
}

class _ComptabilitePageState extends State<ComptabilitePage> {
  late Database _database;
  List<Map<String, dynamic>> _dailySales = [];
  List<Map<String, dynamic>> _monthlySales = [];
  double _totalYearlySales = 0;
  double _totalYearlyProfit = 0;


  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'produits.db');
    _database = await openDatabase(path);
    await _fetchSalesData();
  }

  Future<void> _fetchSalesData() async {
    final currentYear = DateTime.now().year;
    final yearlyResult = await _database.rawQuery(
      '''
  SELECT 
    SUM(amount) AS totalSales, 
    SUM(profit) AS totalProfit 
  FROM sales 
  WHERE strftime("%Y", substr(date, 7, 4) || "-" || substr(date, 4, 2) || "-" || substr(date, 1, 2)) = ?
  ''',
      [currentYear.toString()],
    );


    print(yearlyResult);

    _totalYearlySales = (yearlyResult.first['totalSales'] as num?)?.toDouble() ?? 0.0;
    _totalYearlyProfit = (yearlyResult.first['totalProfit'] as num?)?.toDouble() ?? 0.0;

    print (_totalYearlySales); print (_totalYearlyProfit);

    _dailySales = await _database.rawQuery(
      ''' SELECT  date, SUM(amount) AS totalSales, SUM(profit) AS totalProfit 
  FROM sales 
  GROUP BY date 
  ORDER BY date(date, 'dd-MM-yyyy') DESC 
  LIMIT 365
  ''',
    );

    _dailySales = _dailySales.map((sale) {
      return {
        'date': sale['date'], // La date au format original
        'amount': sale['totalSales'], // Correspond à la somme des montants
        'profit': sale['totalProfit'], // Correspond à la somme des bénéfices
      };
    }).toList();
    print (_dailySales);

    _monthlySales = await _database.rawQuery(
      'SELECT strftime("%m-%Y", date) as month, SUM(amount) as totalSales, SUM(profit) as totalProfit FROM sales GROUP BY month ORDER BY month DESC LIMIT 12',
        );
    print (_dailySales);

    setState(() {});
  }

  Future<Map<String, dynamic>> _fetchSalesDetails(String date, bool isDaily) async {
    final salesDetails = await _database.rawQuery(
      isDaily
          ? '''
        SELECT 
          products.name AS product_name, 
          sales.quantity, 
          sales.amount, 
          sales.profit,
          SUM(sales.amount) AS totalSales, 
          SUM(sales.amount - products.purchase_price * sales.quantity) AS totalProfit
        FROM sales
        INNER JOIN products ON sales.product_id = products.id
        WHERE sales.date = ?
        '''
          : '''
        SELECT 
          products.name AS product_name, 
          sales.quantity, 
          sales.amount, 
          SUM(sales.amount) AS totalSales, 
          SUM(sales.amount - products.purchase_price * sales.quantity) AS totalProfit
        FROM sales
        INNER JOIN products ON sales.product_id = products.id
        WHERE strftime("%m-%Y", sales.date) = ?
        ''',
      [date],
    );

    if (salesDetails.isNotEmpty) {
      return {
        'details': salesDetails.map((sale) {
          return {
            'product_name': sale['product_name'].toString(),
            'quantity': sale['quantity'].toString(),
            'amount': sale['amount'].toString(),
            'profit': sale['profit'].toString(),
          };
        }).toList(),
        'totalSales': salesDetails.first['totalSales'] as double? ?? 0.0,
        'totalProfit': salesDetails.first['totalProfit'] as double? ?? 0.0,
      };
    } else {
      return {
        'details': [],
        'totalSales': 0.0,
        'totalProfit': 0.0,
      };
    }
  }

  Future<Uint8List> generatePDF({
    required String title,
    required String subtitle,
    required List<List<String>> tableData,
    required double totalSales,
    required double totalProfit,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text(subtitle, style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ["Nom du Produit", "Quantité", "Montant encaissé(F CFA)","Bénéfices"],
              data: tableData,
            ),

            pw.SizedBox(height: 20),
            pw.Text(
              'TOTAL : $totalSales F CFA',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'BÉNÉFICE TOTAL : $totalProfit F CFA',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 20),
            pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: 'https://akon-edtech.com',
              width: 30,
              height: 30,
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              "REALISE PAR AKONTA / EDTECH EDITEUR DE LOGICIEL",
              style: pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  String _searchQuery = "";


  Widget _buildSearchField(void Function(String) onChanged, VoidCallback onSearchPressed) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: "Rechercher...",
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.blue),
          onPressed: onSearchPressed,
        ),
      ],
    );
  }

  Widget buildListViewPage({
    required String title,
    required List<Map<String, dynamic>> data,
    required bool isDaily,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [

    Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final date = item['date'];

                return FutureBuilder<Map<String, dynamic>>(
                  future: _fetchSalesDetails(date, isDaily),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Erreur de chargement'));
                    }

                    final totalSales = snapshot.data?['totalSales'] ?? 0.0;
                    final totalProfit = snapshot.data?['totalProfit'] ?? 0.0;

                    return Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        title: Text(date),
                        subtitle: Text(
                          'Recette : ${totalSales.toStringAsFixed(2)} F CFA\n'
                              'Bénéfice : ${totalProfit.toStringAsFixed(2)} F CFA',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            final details = (snapshot.data?['details'] ?? []) as List;

                            final tableData = details.map<List<String>>((dynamic detail) {
                              final detailMap = detail as Map<String, String>;
                              return [
                                detailMap['product_name'] ?? 'Inconnu',
                                detailMap['quantity'] ?? '0',
                                detailMap['amount'] ?? '0',
                                detailMap['profit'] ?? '0',
                              ];
                            }).toList();

                            final totalQuantity = details.fold<int>(
                              0,
                                  (sum, detail) => sum + int.tryParse((detail as Map<String, String>)['quantity'] ?? '0')!,
                            );

                            tableData.add([
                              'Total',
                              totalQuantity.toString(),
                              totalSales.toStringAsFixed(2),
                              totalProfit.toStringAsFixed(2),
                            ]);

                            final pdfBytes = await generatePDF(
                              title: 'Rapport Journalier du $date',
                              subtitle: 'Détails des ventes',
                              tableData: tableData,
                              totalSales: totalSales,
                              totalProfit: totalProfit,
                            );

                            _openPDFViewer(context, pdfBytes);
                          },
                          child: const Text('Afficher PDF'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
      BuildContext parentContext,
      String query,
      List<Map<String, dynamic>> data,
      bool isDaily,
      ) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: Text(
            "Consulter Point des ventes du $query",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Fermer le popup

                final details = await _fetchSalesDetails(query, isDaily);

                if (details == null) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text("Erreur lors de la récupération des détails")),
                  );
                  return;
                }

                final totalSales = details['totalSales'] ?? 0.0;
                final totalProfit = details['totalProfit'] ?? 0.0;
                final detailList = (details['details'] ?? []) as List;

                final tableData = detailList.map<List<String>>((dynamic detail) {
                  final detailMap = detail as Map<String, String>;
                  return [
                    detailMap['product_name'] ?? 'Inconnu',
                    detailMap['quantity'] ?? '0',
                    detailMap['amount'] ?? '0',
                    detailMap['profit'] ?? '0',
                  ];
                }).toList();

                final totalQuantity = detailList.fold<int>(
                  0,
                      (sum, detail) => sum + int.tryParse((detail as Map<String, String>)['quantity'] ?? '0')!,
                );

                tableData.add([
                  'Total',
                  totalQuantity.toString(),
                  totalSales.toStringAsFixed(2),
                  totalProfit.toStringAsFixed(2),
                ]);

                final pdfBytes = await generatePDF(
                  title: 'Rapport Journalier du $query',
                  subtitle: 'Détails des ventes',
                  tableData: tableData,
                  totalSales: totalSales,
                  totalProfit: totalProfit,
                );

                _openPDFViewer(parentContext, pdfBytes);
              },
              child: const Text("Consulter"),
            ),
          ],
        );
      },
    );
  }




  void _openPDFViewer(BuildContext context, Uint8List pdfData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(pdfData: pdfData),
      ),
    );
  }


  Widget _buildMainContainer(String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Point des Ventes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$currentYear',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Recettes totales : ${_totalYearlySales.toStringAsFixed(0)} F CFA',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    'Bénéfices totaux : ${_totalYearlyProfit.toStringAsFixed(0)} F CFA',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildMainContainer(
              'Point Journalier',
              Colors.blue,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => buildListViewPage(
                      title: 'Point Journalier',
                      data: _dailySales,
                      isDaily: true,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class PDFViewerPage extends StatelessWidget {
  final Uint8List pdfData;

  const PDFViewerPage({required this.pdfData, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Visualiseur PDF', style: TextStyle(color: Colors.white)),
      ),
      body: PDFView(pdfData: pdfData),
    );
  }
}



