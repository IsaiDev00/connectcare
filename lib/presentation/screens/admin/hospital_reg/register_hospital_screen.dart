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
                'IMPORTANT',
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
                'Before starting a hospital registration, you must ensure that your mobile device has a readable image of your hospitals CLUES certificate.',
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
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    );
  }
}
