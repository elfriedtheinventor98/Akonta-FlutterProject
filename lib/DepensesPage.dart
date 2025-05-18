/*import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DepensesPage extends StatefulWidget {
  const DepensesPage({super.key});

  @override
  State<DepensesPage> createState() => _DepensesPageState();
}

class _DepensesPageState extends State<DepensesPage> {
  late Database _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'produits.db');
    _database = await openDatabase(path);
  }



  Future<void> _addDepense(String name,int montant) async {
    try {
      final String currentDate = _getCurrentDate();
      await _database.insert(
        'products',
        {
          'name': name,
          'montant': montant,
          'date': currentDate,
        },
        //conflictAlgorithm: ConflictAlgorithm.ignore,
      );

    }
  }


  String _getCurrentDate() {
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showDepenseDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController purchasePriceController = TextEditingController();
    String? photoPath;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Enregistrer une dépense'),
          content: SizedBox(
            height: 380,

            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Ecrire la dépense'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Quantité disponible'),
                ),
                const SizedBox(height: 10),

                const SizedBox(height: 10),

              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final String name = nameController.text.trim();
                final int montant = int.tryParse(quantityController.text.trim()) ?? 0;
                final double purchasePrice = double.tryParse(purchasePriceController.text.trim()) ?? 0.0;

                if (name.isNotEmpty && ) {
                  _addDepense(name, montant, date);
                  Navigator.pop(dialogContext);
                } else {
                  _showSnackbar('Veuillez remplir tous les champs.');
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Liste des Dépenses',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            ElevatedButton.icon(
              onPressed: _showAddDepenseDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                minimumSize: const Size(323, 50), // Largeur et hauteur définies
              ),
              icon: const Icon(Icons.add, color: Colors.white, size: 24), // Taille de l'icône ajustée
              label: const Text(
                'Ajouter un produit',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity, // Prend toute la largeur disponible
              height: 51, // Hauteur définie
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Produits disponibles : ${_products.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Rechercher un produit',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  if (_searchController.text.isNotEmpty &&
                      !product['name']
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase())) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.pink,
                          child: Text('${index + 1}'),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey,
                            image: product['photo'] != null && product['photo'].isNotEmpty
                                ? DecorationImage(
                              image: FileImage(File(product['photo'])),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text('Stock: ${product['quantity']}'),
                              // Text('Prix d'achat: ${product['purchase_price']}'),
                              Text(
                                'Prix d\'achat: ${product['purchase_price'] != null ? product['purchase_price'].toStringAsFixed(2) : "Non défini"}',
                              ),

                            ],
                          ),
                        ),



                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
/*
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DepensesPage extends StatefulWidget {
  const DepensesPage({super.key});

  @override
  State<DepensesPage> createState() => _DepensesPageState();
}

class _DepensesPageState extends State<DepensesPage> {
  late Database _database;
  List<Map<String, dynamic>> _depenses = [];
  double _totalProfit = 0.0;
  double _totalDepenses = 0.0;
  double _finalProfit = 0.0;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'produits.db');
    _database = await openDatabase(path);
    _loadData();
  }

  Future<void> _loadData() async {
    final String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final List<Map<String, dynamic>> depenses = await _database.rawQuery(
        "SELECT * FROM depenses WHERE date LIKE ?", ['%$today%']);
    final List<Map<String, dynamic>> sales = await _database.rawQuery(
        "SELECT SUM(profit) as total_profit FROM sales WHERE date LIKE ?", ['%$today%']);

    double totalProfit = sales.first['total_profit'] ?? 0.0;
    double totalDepenses = depenses.fold(0, (sum, item) => sum + (item['montant'] ?? 0));
    double finalProfit = totalProfit - totalDepenses;

    setState(() {
      _depenses = depenses;
      _totalProfit = totalProfit;
      _totalDepenses = totalDepenses;
      _finalProfit = finalProfit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Liste des Dépenses',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Bénéfice du jour : \$_totalProfit FCFA',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Dépenses totales : \$_totalDepenses FCFA',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _finalProfit >= 0 ? Colors.blue : Colors.orange,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Bénéfice final : \$_finalProfit FCFA',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _depenses.length,
                itemBuilder: (context, index) {
                  final depense = _depenses[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text(
                        depense['name'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Montant: \${depense['montant']} FCFA"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/

import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
//import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DepensesPage extends StatefulWidget {
  const DepensesPage({super.key});

  @override
  State<DepensesPage> createState() => _DepensesPageState();
}

class _DepensesPageState extends State<DepensesPage> {
  late Database _database;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _depenses = [];
  List<Map<String, dynamic>> _sales = [];
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, 'produits.db');
    _database = await openDatabase(path);
    await _loadDepenses();
    await _loadSales();
    await _loadProducts();
  }

  Future<void> _loadDepenses() async {
    final List<Map<String, dynamic>> depenses = await _database.query('depenses');
    setState(() {
      _depenses = depenses;
    });
  }

  Future<void> _loadSales() async {
    final List<Map<String, dynamic>> sales = await _database.query('sales');
    setState(() {
      _sales = sales;
    });
  }

  Future<void> _loadProducts() async {
    final List<Map<String, dynamic>> products = await _database.query('products');
    setState(() {
      _products = products;
    });
  }

  Future<void> _addDepense(String name, int montant) async {
    try {
      final String currentDate = _getCurrentDate();
      await _database.insert(
        'depenses',
        {
          'name': name,
          'montant': montant,
          'date': currentDate,
        },
      );
      await _loadDepenses();
    } catch (e) {
      _showSnackbar('Erreur lors de l\'ajout de la dépense: $e');
    }
  }

  String _getCurrentDate() {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAddDepenseDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController montantController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Enregistrer une dépense'),
          content: SizedBox(
            height: 150,
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Nom de la dépense'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: montantController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Montant de la dépense'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String name = nameController.text.trim();
                final int montant = int.tryParse(montantController.text.trim()) ?? 0;

                if (name.isNotEmpty && montant > 0) {
                  await _addDepense(name, montant);
                  Navigator.pop(dialogContext);
                } else {
                  _showSnackbar('Veuillez remplir tous les champs correctement.');
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  double _calculateDailyProfit(String date) {
    double totalProfit = 0.0;
    for (var sale in _sales) {
      if (sale['date'] == date) {
        totalProfit += sale['profit'] ?? 0.0;
      }
    }
    return totalProfit;
  }

  double _calculateDailyExpenses(String date) {
    double totalExpenses = 0.0;
    for (var depense in _depenses) {
      if (depense['date'].split(' ')[0] == date) {
        totalExpenses += depense['montant'] ?? 0.0;
      }
    }
    return totalExpenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Liste des Dépenses',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _showAddDepenseDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                minimumSize: const Size(323, 50),
              ),
              icon: const Icon(Icons.add, color: Colors.white, size: 24),
              label: const Text(
                'Ajouter une dépense',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _depenses.length,
                itemBuilder: (context, index) {
                  final depense = _depenses[index];
                  final String date = depense['date'].split(' ')[0];
                  final double dailyProfit = _calculateDailyProfit(date);
                  final double dailyExpenses = _calculateDailyExpenses(date);
                  final double netProfit = dailyProfit - dailyExpenses;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dépense: ${depense['name']}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text('Montant: ${depense['montant']} FCFA'),
                        Text('Date: ${depense['date']}'),
                        const SizedBox(height: 10),
                        Text(
                          'Bénéfice net du jour: ${netProfit.toStringAsFixed(2)} FCFA',
                          style: const TextStyle(fontSize: 14, color: Colors.green),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
