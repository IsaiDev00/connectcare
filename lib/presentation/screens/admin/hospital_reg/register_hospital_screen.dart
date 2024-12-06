import 'package:flutter/material.dart';

class RegisterHospitalScreen extends StatefulWidget {
  const RegisterHospitalScreen({super.key});

  @override
  RegisterHospitalScreenState createState() => RegisterHospitalScreenState();
}

class RegisterHospitalScreenState extends State<RegisterHospitalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                'Before starting the registration of a hospital, you must make sure that your mobile device has airtime, that you have the hospitals CLUES certificate and the telephone number registered there at hand.',
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
