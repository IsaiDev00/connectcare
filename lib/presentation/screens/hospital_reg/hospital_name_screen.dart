import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HospitalNameScreen extends StatefulWidget {
  const HospitalNameScreen({super.key});

  @override
  HospitalNameScreenState createState() => HospitalNameScreenState();
}

class HospitalNameScreenState extends State<HospitalNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool isButtonEnabled = false;
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        isButtonEnabled = _nameController.text.isNotEmpty;
      });
    });
  }

  Future<void> _registerHospital() async {
    try {
      // Obtener CLUES desde SharedPreferences
      final cluesData = await _sharedPreferencesService.getCluesCode();
      // Obtener id_personal desde SharedPreferences
      final userId = await _sharedPreferencesService.getUserId();

      if (cluesData != null && userId != null) {
        final clues = cluesData;

        // Realiza la solicitud al backend para crear el registro de hospital y administrador
        final response = await http.post(
          Uri.parse('$baseUrl/hospital/registrarHospital'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'clues': clues, // Enviar el CLUES obtenido
            'nombre': _nameController.text
                .trim(), // Nombre del hospital que se ingresa en la UI
            'id_personal': userId, // id_personal obtenido
          }),
        );

        _responseHospitalRegister(response);
      } else {
        String mensaje = 'Faltan datos necesarios para registrar el hospital.';
        if (cluesData == null) {
          mensaje = 'No se encontró un registro de CLUES válido.';
        }
        if (userId == null) mensaje = 'No se encontró un ID de usuario válido.';

        _validationsHospitalRegister(mensaje);
      }
    } catch (e) {
      _responseError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nombre del Hospital'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Ahora debes agregar un nombre al hospital, procura ser lo más claro posible.\nEj. IMSS Clinica 14',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Ingresa el nombre del hospital',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isButtonEnabled
                  ? () async {
                      await _registerHospital();
                    }
                  : null,
              child: const Text('Siguiente'),
            ),
          ],
        ),
      ),
    );
  }

  void _responseHospitalRegister(response) {
    if (response.statusCode == 201) {
      showCustomSnackBar(
          context, 'Hospital y Administrador registrados exitosamente.');
      Navigator.pushNamed(context, '/adminHomeScreen');
    } else {
      throw Exception(
          'Error en la respuesta del servidor: ${response.statusCode} - ${response.body}');
    }
  }

  void _validationsHospitalRegister(mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
      ),
    );
  }

  void _responseError(e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al registrar el hospital: $e'),
      ),
    );
  }
}
