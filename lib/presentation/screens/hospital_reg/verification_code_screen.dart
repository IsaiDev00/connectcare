import 'package:connectcare/presentation/screens/hospital_reg/hospital_name_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class VerificationCodeScreen extends StatefulWidget {
  final String detectedText;

  const VerificationCodeScreen({super.key, required this.detectedText});

  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  late int verificationCode;

  @override
  void initState() {
    super.initState();
    _generateVerificationCode();
  }

  void _generateVerificationCode() {
    setState(() {
      verificationCode = Random().nextInt(900000) + 100000;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de Código'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: const Text(
                'Tu código de verificación es:',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '\$verificationCode',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const Text(
              'Deberás teclear este código al contestar la llamada de verificación desde el teléfono proporcionado al CLUES.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HospitalNameScreen(detectedText: widget.detectedText),
                  ),
                );
              },
              child: const Text('Generar llamada'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
