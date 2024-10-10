import 'package:flutter/material.dart';

class RegisterHospitalScreen extends StatefulWidget {
  const RegisterHospitalScreen({super.key});

  @override
  _RegisterHospitalScreen createState() => _RegisterHospitalScreen();
}

class _RegisterHospitalScreen extends State<RegisterHospitalScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Importante
            Center(
              child: const Text(
                'IMPORTANTE',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 20),

            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: const Text(
                'Antes de iniciar el registro de un hospital, debe asegurarse que su dispositivo movil cuenta con tiempo aire, que tiene el certificado CLUES del hopital y el telefono ahi registrado a la mano.',
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Botón de acción
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/submitCluesScreen');
                
              },
              child: const Text('Entendido'),
            ),
          ],
        ),
      ),
    );
  }

}