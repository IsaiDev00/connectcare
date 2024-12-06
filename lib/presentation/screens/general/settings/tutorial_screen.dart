import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial de Uso'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(Icons.login, color: theme.colorScheme.primary),
            title: const Text('Inicio de sesión'),
            subtitle: const Text('Aprende cómo iniciar sesión en la app.'),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.person, color: theme.colorScheme.primary),
            title: const Text('Perfil'),
            subtitle: const Text('Configura y edita tu perfil fácilmente.'),
          ),
          const Divider(),
          ListTile(
            leading:
                Icon(Icons.local_hospital, color: theme.colorScheme.primary),
            title: const Text('Gestión Hospitalaria'),
            subtitle: const Text(
                'Conoce cómo administrar servicios, procedimientos y más.'),
          ),
          const Divider(),
          ListTile(
            leading:
                Icon(Icons.support_agent, color: theme.colorScheme.primary),
            title: const Text('Soporte'),
            subtitle: const Text(
                'Accede a la ayuda y soporte técnico en caso de problemas.'),
          ),
        ],
      ),
    );
  }
}
