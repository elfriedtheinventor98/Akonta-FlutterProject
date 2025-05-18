import 'package:flutter/material.dart';

class ListeResultatsPage extends StatelessWidget {
  final Map<String, dynamic> results;

  ListeResultatsPage({required this.results});

  Widget _buildObservationCard(String title, Color color, String value, String observation) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Concentration: $value',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              observation,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String malariaObs = double.parse(results['malaria'].split(' ')[0]) > 1000
        ? 'Patient malade (Paludisme détecté)'
        : 'Patient sain';

    String hbObs = double.parse(results['hb'].split(' ')[0]) < 12.0
        ? 'Taux faible: Anémie suspectée'
        : 'Taux normal';

    String hctObs = double.parse(results['hct'].split(' ')[0]) < 36.0
        ? 'Hématocrite faible: Possible anémie'
        : 'Hématocrite normal';

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildObservationCard(
              'Analyse de la malaria',
              Colors.blueAccent,
              results['malaria'],
              malariaObs,
            ),
            SizedBox(height: 20),
            _buildObservationCard(
              'Analyse NFS',
              Colors.greenAccent,
              'Hb: ${results['hb']}\nHct: ${results['hct']}',
              '$hbObs\n$hctObs',
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(150, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}
