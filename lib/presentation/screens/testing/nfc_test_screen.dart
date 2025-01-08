import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NFCExampleScreen extends StatefulWidget {
  const NFCExampleScreen({super.key});

  @override
  _NFCExampleScreenState createState() => _NFCExampleScreenState();
}

class _NFCExampleScreenState extends State<NFCExampleScreen> {
  static const platform = MethodChannel('com.tu_paquete/nfc');

  String _status = "Acerque una tarjeta NFC para interactuar...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NFC con MIFARE Classic"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: writeNFC,
                child: const Text("Escribir 'Adios' en tarjeta NFC"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: readNFC,
                child: const Text("Leer tarjeta NFC"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> writeNFC() async {
    setState(() {
      _status = "Esperando tarjeta NFC para escribir...";
    });

    try {
      final bool result = await platform.invokeMethod('writeNFC', {
        'block': 8,
        'data': 'Adios',
      });

      if (result) {
        setState(() {
          _status = "¡Mensaje escrito exitosamente en la tarjeta!";
        });
      } else {
        setState(() {
          _status = "Error al escribir en la tarjeta.";
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _status = "Error al escribir en la tarjeta: ${e.message}";
      });
    }
  }

  Future<void> readNFC() async {
    setState(() {
      _status = "Esperando tarjeta NFC para leer...";
    });

    try {
      final String? data = await platform.invokeMethod('readNFC', {
        'block': 8,
      });

      if (data != null && data.isNotEmpty) {
        setState(() {
          _status = "Texto leído: $data";
        });
      } else {
        setState(() {
          _status = "Error al leer la tarjeta.";
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _status = "Error al leer la tarjeta: ${e.message}";
      });
    }
  }
}
