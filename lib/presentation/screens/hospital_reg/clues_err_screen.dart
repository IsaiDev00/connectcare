import 'package:flutter/material.dart';

class CluesErrScreen extends StatefulWidget {
  const CluesErrScreen({super.key});

  @override
  CluesErrScreenState createState() => CluesErrScreenState();
}

class CluesErrScreenState extends State<CluesErrScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error de Certificado CLUES'),
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
                'El certificado CLUES no es reconocible, la imagen no es legible.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/submitCluesScreen');
              },
              child: const Text('Volver a Enviar'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/mainScreen');
              },
              child: const Text('Volver al Menú'),
            ),
          ],
        ),
      ),
    );
  }
}
