import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:connectcare/data/services/user_service.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeData(); // Carga y guarda datos al inicio
  }

  Future<void> _initializeData() async {
    // await _saveData(cluesdoc, id); // Guarda los valores iniciales
    final userService = UserService();
    await userService.updateFirebaseTokenAndSendNotification();
    setState(() {}); // Fuerza la reconstrucción para sincronizar UI
    
  }

  // Guarda los datos en SharedPreferences
  /*Future<void> _saveData(String newClues, String newId) async {
    await _sharedPreferencesService.saveClues(newClues);
    await _sharedPreferencesService.saveUserId(newId);
    print("Datos guardados: CLUES $newClues, ID $newId");

    // Verifica que los datos se hayan guardado correctamente
    final savedClues = await _sharedPreferencesService.getClues();
    final savedId = await _sharedPreferencesService.getUserId();
    print("Datos verificados: CLUES $savedClues, ID $savedId");
  }*/

  Future<String?> _getHospitalName() async {
    // Obtiene el CLUES actual desde SharedPreferences
    final clues = await _sharedPreferencesService.getClues();
    print("CLUES leído desde SharedPreferences: $clues"); // Debug log

    if (clues != null && clues.isNotEmpty) {
      var url = Uri.parse('$baseUrl/hospital/nombre/$clues');
      var response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        print("Nombre del hospital obtenido: ${responseBody['nombre']}");
        return responseBody['nombre'];
      } else {
        debugPrint('Error al obtener nombre del hospital: ${response.body}');
        return null;
      }
    } else {
      debugPrint('Error: CLUES vacío o no disponible');
      return null;
    }
  }

  // Cambia el CLUES y obtiene el nombre actualizado del hospital
  Future<void> updateClues(String newClues) async {
    //await _saveData(newClues, id); // Actualiza el CLUES y guarda el ID
    final hospitalName =
        await _getHospitalName(); // Obtén el nuevo nombre del hospital

    if (hospitalName != null) {
      print("Nombre del hospital después de actualizar: $hospitalName");
    } else {
      print("No se pudo obtener el nombre del hospital después de actualizar.");
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
              title: const Text('Settings'),
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
              future:
                  _getHospitalName(), // Llama al Future que obtiene el nombre
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Mientras espera los datos
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
                  // Muestra el nombre del hospital si está disponible
                  return Text(
                    snapshot.data!,
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
