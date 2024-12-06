import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre Nosotros'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Icon(
                Icons.info,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'ConnectCare',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Nuestra misión es conectar y facilitar la gestión de hospitales, pacientes y familiares con la tecnología más avanzada.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text(
              '¿Tienes preguntas? Contáctanos en:',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Email1: guillermoisailh@gmail.com\nEmail2: carlosivanb@gmail.com\nTeléfono1: +52 33 2354 8237\nTeléfono2: +52 33 3328 6272',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
