import 'package:akonta/Resultats.dart';
import 'package:flutter/material.dart';
//import 'package:intl/date_symbol_data_file.dart';

import 'Mainscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await initializeDateFormatting('fr_FR', null); // Si nécessaire, décommentez cette ligne
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akonta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Autres éléments que tu souhaites personnaliser avec la couleur bleue foncée
      ),
     // home: const Mainscreen(),
      home: Mainscreen(), // Assurez-vous que MainScreen est défini
    );
  }
}
