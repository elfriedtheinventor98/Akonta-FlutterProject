

import 'package:flutter/material.dart';
import 'ManagerPage.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Container incurvé pour l'image
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/Captureboutiquier.png', // Remplacez par le chemin de votre image
                    fit: BoxFit.cover,
                    height: 150,
                    width: 224,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Champ de saisie incurvé avec hauteur et largeur définies
              Container(
                height: 60, // Hauteur du champ
                width: 230, // Largeur du champ
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9), // Légère transparence
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    textAlign: TextAlign.center, // Centrer le texte
                    decoration: InputDecoration(
                      hintText: "Mot de passe",
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.5), // Légère transparence
                      ),
                      border: InputBorder.none, // Pas de bordure visible
                    ),
                    onChanged: (value) {
                      if (value == "0000") {
                        // Redirection vers ManagerPage si le mot de passe est correct
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ManagerPage()),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
