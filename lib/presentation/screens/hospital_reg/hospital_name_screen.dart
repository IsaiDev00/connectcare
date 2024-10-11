import 'package:flutter/material.dart';

class HospitalNameScreen extends StatefulWidget {
  const HospitalNameScreen({super.key});

  @override
  _HospitalNameScreen createState() => _HospitalNameScreen();
}

class _HospitalNameScreen extends State<HospitalNameScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nombre del Hospital'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Ahora debes agregar un nombre al hospital, procura ser lo más claro posible.\nEj. IMSS Clinica 14',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Ingresa el nombre del hospital',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _nameController.text.isNotEmpty
                  ? () {
                      // Lógica para ir a la siguiente pantalla
                    }
                  : null,
              child: const Text('Siguiente'),
            ),
          ],
        ),
      ),
    );
  }
}
