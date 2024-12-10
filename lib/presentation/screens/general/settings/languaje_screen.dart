import 'package:flutter/material.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Idioma'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(Icons.language, color: theme.colorScheme.primary),
            title: const Text('Español'),
            onTap: () {
              // Lógica para cambiar el idioma a Español
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Idioma cambiado a Español')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.language, color: theme.colorScheme.primary),
            title: const Text('English'),
            onTap: () {
              // Lógica para cambiar el idioma a Inglés
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language changed to English')),
              );
            },
          ),
        ],
      ),
    );
  }
}
