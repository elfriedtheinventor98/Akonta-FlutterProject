import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:image_picker/image_picker.dart';

class ListeProduits extends StatefulWidget {
  const ListeProduits({super.key});

  @override
  State<ListeProduits> createState() => _ListeProduitsState();
}

class _ListeProduitsState extends State<ListeProduits> {
  late Database _database;
  final List<Map<String, dynamic>> _products = [];
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      p.join(await getDatabasesPath(), 'produits.db'),
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE  products(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE, purchase_price REAL, date TEXT NOT NULL, quantity INTEGER, photo TEXT)');
        await db.execute(
            'CREATE TABLE  sales ('
                'id INTEGER PRIMARY KEY AUTOINCREMENT, '
                'product_id INTEGER NOT NULL, '
                'quantity INTEGER NOT NULL, '
                'price REAL NOT NULL, '
                'amount REAL, '
                'profit REAL, '
                'date TEXT NOT NULL, '
                'FOREIGN KEY (product_id) REFERENCES products (id))');

        await db.execute(
            'CREATE TABLE  depenses(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT , montant INTEGER, date TEXT NOT NULL)');

      },
      version: 1,
    );
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    final List<Map<String, dynamic>> products = await _database.query('products');
    setState(() {
      _products.clear();
      _products.addAll(products);
    });
  }


  Future<void> _addProduct(String name, int quantity, double purchasePrice, String photoPath) async {
    try {
      final String currentDate = _getCurrentDate();
      await _database.insert(
        'products',
        {
          'name': name,
          'quantity': quantity,
          'purchase_price': purchasePrice,
          'photo': photoPath,
          'date': currentDate,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      _loadProducts();
    } catch (e) {
      _showSnackbar('Produit déjà existant.');
    }
  }


 String _getCurrentDate() {
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAddProductDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController purchasePriceController = TextEditingController();
    String? photoPath;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Ajouter un produit'),
          content: SizedBox(
            height: 380,

            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Nom du produit'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Quantité disponible'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: purchasePriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Prix d\'achat par unité'),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      photoPath = image.path;
                      _showSnackbar('Photo ajoutée avec succès.');
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Prendre une photo'),
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
              onPressed: () {
                final String name = nameController.text.trim();
                final int quantity = int.tryParse(quantityController.text.trim()) ?? 0;
                final double purchasePrice = double.tryParse(purchasePriceController.text.trim()) ?? 0.0;

                if (name.isNotEmpty && quantity > 0 && purchasePrice > 0.0 && photoPath != null) {
                  _addProduct(name, quantity, purchasePrice, photoPath!);
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
          'Liste des Produits',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            ElevatedButton.icon(
              onPressed: _showAddProductDialog,
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
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                final TextEditingController nameController = TextEditingController(
                                    text: product['name']);
                                final TextEditingController purchasePriceController = TextEditingController(
                                    text: product['purchase_price']?.toString());


                                final TextEditingController quantityController = TextEditingController(
                                    text: product['quantity'].toString());

                                return
                                  AlertDialog(
                                    title: const Text('Modifier le produit'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: nameController,
                                            decoration: const InputDecoration(labelText: 'Nom du produit'),
                                          ),
                                          TextField(
                                            controller: quantityController,
                                            decoration: const InputDecoration(labelText: 'Quantité'),
                                            keyboardType: TextInputType.number,
                                          ),
                                          TextField(
                                            controller: purchasePriceController,
                                            decoration: const InputDecoration(labelText: 'Prix d\'achat'),
                                            keyboardType: TextInputType.number,
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context), // Annuler l'édition
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final updatedName = nameController.text.trim();
                                          final updatedQuantity = int.tryParse(quantityController.text.trim()) ?? 0;
                                          final updatedPurchasePrice = double.tryParse(purchasePriceController.text.trim()) ?? -1;

                                          if (updatedName.isNotEmpty && updatedQuantity > 0 && updatedPurchasePrice >= 0) {
                                            // Mise à jour dans la base de données
                                            await _database.update(
                                              'products',
                                              {
                                                'name': updatedName,
                                                'quantity': updatedQuantity,
                                                'purchase_price': updatedPurchasePrice,
                                              },
                                              where: 'id = ?',
                                              whereArgs: [product['id']],
                                            );
                                            Navigator.pop(context);
                                            await _loadProducts();
                                            _showSnackbar('Produit modifié avec succès.');
                                          } else {
                                            _showSnackbar('Veuillez entrer des informations valides.');
                                          }
                                        },
                                        child: const Text('Enregistrer'),
                                      ),
                                    ],
                                  );


                          },
                            );
                          },
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Confirmer la suppression'),
                                  content: const Text('Voulez-vous vraiment supprimer ce produit ?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Non'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Oui'),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirm == true) {
                              await _database.delete(
                                'products',
                                where: 'id = ?',
                                whereArgs: [product['id']],
                              );
                              _showSnackbar('Produit supprimé avec succès.');
                              await _loadProducts();
                            }
                          },
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
