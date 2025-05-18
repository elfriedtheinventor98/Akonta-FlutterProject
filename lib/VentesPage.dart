import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

class VentesPage extends StatefulWidget {
  const VentesPage({super.key});

  @override
  State<VentesPage> createState() => _VentesPageState();
}

class _VentesPageState extends State<VentesPage> {
  late Database _database;
  final Map<int, double> _lastPrices = {};

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final dbFullPath = p.join(dbPath, 'produits.db');

    _database = await openDatabase(
      dbFullPath,
      version: 1, // Version actuelle de la base de données
    );

    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final List<Map<String, dynamic>> products = await _database.query('products');
    setState(() {
      _products = products;
      _filteredProducts = products;
    });
  }

  void _filterProducts(String query) {
    final filtered = _products.where((product) {
      final name = product['name'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredProducts = filtered;
    });
  }

 /* Future<void> _sellProduct(Map<String, dynamic> product) async {
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController priceController = TextEditingController(
      // Pré-remplit avec le dernier prix si disponible, sinon vide
      //text: _lastPrices[product['id']]?.toString() ?? '',
    );

    final int currentStock = (product['quantity'] as int?) ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Vendre ${product['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantité à vendre',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Récemment : ${_lastPrices[product['id']]?.toString() ?? ""}',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final int quantity = int.tryParse(quantityController.text) ?? -1;
                final double price = double.tryParse(priceController.text) ?? -1.0;

                if (quantity <= 0 || price <= 0) {
                  _showSnackbar('Veuillez entrer une quantité et un prix valides.');
                  return;
                }

                if (quantity > currentStock) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Le STOCK EST FINI.', style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Mise à jour du dernier prix unitaire
                _lastPrices[product['id']] = price;

                // Appel de _processSale avec le prix
                await _processSale(product,sale, quantity, price);

                // Recharger les produits
                await _loadProducts();

                // Fermer le popup
                Navigator.pop(dialogContext);

                // Afficher un message de confirmation
                _showSnackbar('Vente enregistrée avec succès.');
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processSale(Map<String, dynamic> product, sale,int quantity, double sellingPrice) async {
    final double purchasePrice = product['purchase_price'];
    final double sellingPrice = sale['price'];
    final double amount = sellingPrice * quantity;
    //final double amount = sellingPrice * quantity;
    final double profit = amount - (purchasePrice * quantity);

    final String saleDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // Insérer la vente dans la table "sales"
    await _database.insert('sales', {
      'product_id': product['id'],
      'quantity': quantity,
      'price': purchasePrice,
      'amount': amount,
      'profit': profit,
      'date': saleDate,
    });

    // Mettre à jour le stock dans la table "products"
    await _database.update(
      'products',
      {'quantity': product['quantity'] - quantity},
      where: 'id = ?',
      whereArgs: [product['id']],
    );
  }
*/

  Future<void> _sellProduct(Map<String, dynamic> product) async {
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController priceController = TextEditingController(
      // Pré-remplit avec le dernier prix si disponible, sinon vide
      //text: _lastPrices[product['id']]?.toString() ?? '',
    );

    final int currentStock = (product['quantity'] as int?) ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Vendre ${product['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantité à vendre',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Récemment à: ${_lastPrices[product['id']]?.toString() ?? ""}',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Récupérer et valider les entrées
                final int quantity = int.tryParse(quantityController.text) ?? -1;
                final double price = double.tryParse(priceController.text) ?? -1.0;

                if (quantity <= 0 || price <= 0) {
                  _showSnackbar('Veuillez entrer une quantité et un prix valides.');
                  return;
                }

                if (quantity > currentStock) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Le stock est insuffisant.',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Mettre à jour le dernier prix unitaire
                _lastPrices[product['id']] = price;

                // Créer une entrée "vente" fictive pour passer à _processSale
                final Map<String, dynamic> sale = {
                  'price': price, // Le prix unitaire de vente
                };

                // Appeler _processSale avec les données
                await _processSale(product, sale, quantity, price);

                // Recharger les produits pour mettre à jour l'affichage
                await _loadProducts();

                // Fermer le popup
                Navigator.pop(dialogContext);

                // Afficher un message de confirmation
                _showSnackbar('Vente enregistrée avec succès.');
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processSale(Map<String, dynamic> product, Map<String, dynamic> sale, int quantity, double sellingPrice) async {
    // Récupérer le prix d'achat depuis la table "products"
    final double purchasePrice = product['purchase_price'] ?? 0.0;
    final double sellingPrice = sale['price'];
    // Calculer le montant total de la vente et le bénéfice
    final double amount = sellingPrice * quantity; // Montant total de la vente
    final double profit = amount - (purchasePrice * quantity); // Bénéfice réalisé

    // Date de la vente
    final String saleDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // Insérer les informations de la vente dans la table "sales"
    await _database.insert('sales', {
      'product_id': product['id'],       // ID du produit
      'quantity': quantity,              // Quantité vendue
      'price': sellingPrice,             // Prix unitaire de vente
      'amount': amount,                  // Montant total de la vente
      'profit': profit,                  // Bénéfice
      'date': saleDate,                  // Date de la vente
    });

    // Mettre à jour le stock disponible dans la table "products"
    await _database.update(
      'products',
      {
        'quantity': (product['quantity'] as int) - quantity, // Réduire le stock
      },
      where: 'id = ?',
      whereArgs: [product['id']],
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Enregistrer une vente',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _filterProducts,
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
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
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
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _sellProduct(product),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text(
                            'Vendre',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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

