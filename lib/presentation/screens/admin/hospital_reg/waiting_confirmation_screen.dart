import 'package:flutter/material.dart';

class WaitingConfirmationScreen extends StatefulWidget {
  const WaitingConfirmationScreen({super.key});

  @override
  _WaitingConfirmationScreen createState() => _WaitingConfirmationScreen();
}

class _WaitingConfirmationScreen extends State<WaitingConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting Confirmation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.hourglass_empty,
              size: 60,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              'Your application is under review.\nPlease wait for our confirmation.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
