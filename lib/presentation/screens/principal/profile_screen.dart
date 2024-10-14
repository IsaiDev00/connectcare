import 'package:flutter/material.dart';
import 'package:connectcare/data/repositories/table/personal_repository.dart';
import 'package:connectcare/services/shared_preferences_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  final PersonalRepository _personalRepository = PersonalRepository();
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

  Future<void> _loadUserData() async {
    try {
      final userId = await _sharedPreferencesService.getUserId();
      if (userId != null) {
        final userData = await _personalRepository.getById(int.parse(userId));
        if (userData != null) {
          setState(() {
            userName = userData['nombre'] ?? 'Nombre no disponible';
            userEmail =
                userData['correo_electronico'] ?? 'Correo no disponible';
            userPhone = userData['telefono'] ?? 'Teléfono no disponible';
          });
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
