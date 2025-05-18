import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ListeResultats.dart';

class ResultatsPage extends StatefulWidget {
  @override
  _ResultatsPageState createState() => _ResultatsPageState();
}

class _ResultatsPageState extends State<ResultatsPage> {
  BluetoothDevice? _connectedDevice;
  bool _isLoading = false;
  String _receivedData = '';
  double _progress = 0.0;

  Future<void> _connectAndReceiveData() async {
    setState(() => _isLoading = true);

    try {
      // Scan pour les appareils BLE
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 15));

      // Écoute des résultats du scan
      FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult result in results) {
          if (result.device.name == 'BLE-LINK') {
            await FlutterBluePlus.stopScan();
            _connectedDevice = result.device;

            // Connexion à l'appareil
            await _connectedDevice!.connect();

            // Découverte des services
            List<BluetoothService> services = await _connectedDevice!.discoverServices();

            for (BluetoothService service in services) {
              for (BluetoothCharacteristic characteristic in service.characteristics) {
                // Écoute des caractéristiques de notification
                if (characteristic.properties.notify) {
                  await characteristic.setNotifyValue(true);
                  characteristic.value.listen((value) {
                    String newData = String.fromCharCodes(value);
                    setState(() {
                      _receivedData += newData;
                      _progress = _receivedData.length / 100; // Ajuster selon la taille attendue
                    });

                    // Si réception complète
                    if (newData.contains('Fin')) {
                      _navigateToResultList();
                    }
                  });
                }
              }
            }
          }
        }
      });
    } catch (e) {
      print('Erreur: $e');
      setState(() => _isLoading = false);
    }
  }

  void _navigateToResultList() {
    // Parsing des données
    Map<String, dynamic> results = {};
    List<String> lines = _receivedData.split('\n');
    for (String line in lines) {
      if (line.contains('Malaria')) results['malaria'] = line.split(': ')[1];
      if (line.contains('Hb')) results['hb'] = line.split(': ')[1];
      if (line.contains('Hct')) results['hct'] = line.split(': ')[1];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListeResultatsPage(results: results),
      ),
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900],
            minimumSize: Size(200, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: _connectAndReceiveData,
          child: Text(
            'Importer les Résultats',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
