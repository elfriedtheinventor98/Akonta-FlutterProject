import 'package:akonta/DepensesPage.dart';
import 'package:flutter/material.dart';

import 'package:akonta/DocumentsPage.dart';
import 'package:akonta/ListeProduits.dart';


import 'ComptabilitePage.dart';

import 'VentesPage.dart';

class ManagerPage extends StatefulWidget {
  const ManagerPage({super.key});

  @override
  State<ManagerPage> createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  int _selectedIndex = 0; // Variable pour suivre l'élément sélectionné

  // Méthode pour gérer les actions de la barre de navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Actions spécifiques à chaque élément du BottomNavigationBar
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ManagerPage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ListeProduits()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DocumentsPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DepensesPage()),
        );
        break;

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: const Center(
          child: Text(
            "Gestionnaire des activités",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        automaticallyImplyLeading: false, // Supprime le bouton retour
      ),
      body:
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Card pour la Comptabilité
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ComptabilitePage()),
                  );
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16), // Ajoute de l'espace en dessous
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.account_balance, color: Colors.white, size: 40),
                      SizedBox(width: 10),
                      Text(
                        "Comptabilité",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Card pour
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DocumentsPage()),
                  );
                },
                child: Container(
                  height: 110,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16), // Ajoute de l'espace en dessous
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.folder_copy, color: Colors.white, size: 40),
                      SizedBox(width: 10),
                      Text(
                        "Documents",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Card pour la Liste des Profs
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ListeProduits()),
                  );
                },
                child: Container(
                  height: 110,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16), // Ajoute de l'espace en dessous
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.inventory_outlined, color: Colors.white, size: 40),
                      SizedBox(width: 10),
                      Text(
                        "Liste des Produits",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Card pour les Statistiques Annuelles
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VentesPage()),
                  );
                },
                child: Container(
                  height: 110,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16), // Ajoute de l'espace en dessous
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 40),
                      SizedBox(width: 10),
                      Text(
                        "Ventes",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),


      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[200],
        currentIndex: _selectedIndex, // Suivi de l'élément sélectionné
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled, color: Colors.black),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_rounded, color: Colors.black),
            label: 'Ajouter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder, color: Colors.black),
            label: 'Documents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card, color: Colors.black),
            label: 'Dépenses',
          ),

        ],
        selectedLabelStyle: const TextStyle(color: Colors.black),
        unselectedLabelStyle: const TextStyle(color: Colors.black),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
      ),
    );
  }
}
