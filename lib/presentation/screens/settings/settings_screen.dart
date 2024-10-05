import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreen createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Botón para regresar
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/editProfile');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.white, // Fondo blanco
                side: const BorderSide(color: Colors.black), // Contorno negro
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text('Editar perfil'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/language');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text('Idioma'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/tutorial');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text('Tutorial de uso'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/aboutUs');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text('Sobre nosotros'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/feedback');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text('Quejas y sugerencias'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red, backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.red), // Contorno rojo
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
