import 'package:easy_localization/easy_localization.dart';
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
        title: Text('Waiting Confirmation'.tr()),
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
            Text(
              'Your application is under review.\nPlease wait for our confirmation.'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
