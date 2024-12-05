import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({super.key});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  String? verificationCode = "";
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  @override
  void initState() {
    super.initState();
    fetchVerificationCode();
  }

  Future<void> fetchVerificationCode() async {
    // Obtiene el userId desde SharedPreferences
    final userId = await _sharedPreferencesService.getUserId();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ID: $userId"),
        ),
      );
    }

    if (userId != null) {
      // Llama al endpoint del backend para obtener el código de verificación
      final response = await http.post(
        Uri.parse('$baseUrl/codigo/generateCode'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 201) {
        // Decodifica la respuesta JSON y obtiene el código de verificación
        final data = jsonDecode(response.body);
        setState(() {
          verificationCode = data['code'];
        });

        // Guarda el código en SharedPreferences
        await _sharedPreferencesService
            .saveVerificationCode(verificationCode ?? '');
      } else {
        throw Exception('Error al generar el código de verificación');
      }
    } else {
      throw Exception('ID de usuario no encontrado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de Código'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Tu código de verificación es:',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                verificationCode ?? 'Generando...',
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Deberás teclear este código al contestar la llamada de verificación desde el teléfono proporcionado al CLUES.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/hospitalNameScreen');
              },
              child: const Text('Generar llamada'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
