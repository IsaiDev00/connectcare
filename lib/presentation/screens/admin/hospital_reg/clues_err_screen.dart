import 'package:easy_localization/easy_localization.dart';
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
        title: Text('Error de Certificado CLUES'.tr()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text(
                'El certificado CLUES no es reconocible, la imagen no es legible.'.tr(),
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/submitCluesScreen');
              },
              child: Text('Volver a Enviar'.tr()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/mainScreen');
              },
              child: Text('Volver al Menú'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
