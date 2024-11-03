import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  AdminHomeScreenState createState() => AdminHomeScreenState();
}

class AdminHomeScreenState extends State<AdminHomeScreen> {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  Future<String?> _getHospitalName() async {
    final clues = await _sharedPreferencesService.getClues();

    if (clues != null && clues.isNotEmpty) {
      var url = Uri.parse('$baseUrl/hospital/nombre/$clues');
      var response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        return responseBody['nombre']; // Devuelve el nombre del hospital
      } else {
        debugPrint('Error: ${response.body}');
        return null;
      }
    } else {
      debugPrint('Error: Clues is empty');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio del Administrador'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Info'),
              onTap: () {
                // Navegar a la pantalla de perfil
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ajustes'),
              onTap: () {
                // Navegar a la pantalla de ajustes
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            FutureBuilder<String?>(
              future: _getHospitalName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text(
                    'Error al cargar el nombre del hospital',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  );
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Text(
                    'Hospital no encontrado',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  );
                } else {
                  return Text(
                    snapshot.data ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  );
                }
              },
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/hospitalFeaturesScreen');
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Iniciar!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
