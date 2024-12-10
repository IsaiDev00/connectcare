import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quejas y Sugerencias'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Por favor, comparte tus quejas o sugerencias para mejorar nuestro servicio.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Escribe aquí tus comentarios...',
                hintStyle: theme.textTheme.headlineSmall,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gracias por tu comentario')),
                );
              },
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}
