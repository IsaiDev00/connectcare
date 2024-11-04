import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectcare/data/services/shared_preferences_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  String? userName;
  String? userEmail;
  String? userPhone;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Método para cargar los datos del usuario desde el backend
  Future<void> _loadUserData() async {
    try {
      final userId = await _sharedPreferencesService.getUserId();
      debugPrint('User ID: $userId');
      if (userId != null) {
        // Realizar la solicitud al backend
        final url = Uri.parse('$baseUrl/personal/$userId');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body);
          setState(() {
            userName = userData['nombre'] ?? 'Nombre no disponible';
            userEmail =
                userData['correo_electronico'] ?? 'Correo no disponible';
            userPhone = userData['telefono'] ?? 'Teléfono no disponible';
          });
        } else if (response.statusCode == 404) {
          setState(() {
            userName = 'Usuario no encontrado';
            userEmail = '';
            userPhone = '';
          });
        } else {
          throw Exception('Error al obtener los datos del usuario');
        }
      }
    } catch (e) {
      debugPrint('Error al cargar los datos del usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Image.asset(
                'assets/images/image.png',
                height: 150,
              ),
            ),
            const SizedBox(height: 40),

            // Nombre del usuario
            Text(
              userName ?? 'Cargando...',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Correo del usuario
            Text(
              userEmail ?? 'Cargando...',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),

            // Teléfono del usuario
            Text(
              userPhone ?? 'Cargando...',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
