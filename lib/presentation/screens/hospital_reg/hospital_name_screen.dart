import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/repositories/table/hospital_repository.dart';
import 'package:connectcare/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HospitalNameScreen extends StatefulWidget {
  const HospitalNameScreen({super.key});

  @override
  _HospitalNameScreen createState() => _HospitalNameScreen();
}

class _HospitalNameScreen extends State<HospitalNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool isButtonEnabled = false;
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();
  final HospitalRepository _hospitalRepository = HospitalRepository();

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
      final cluesData = await _sharedPreferencesService
          .getCluesCode(); // Obtener CLUES desde SharedPreferences
      if (cluesData != null) {
        final clues = cluesData;

        // Realiza la solicitud al backend para crear el registro de hospital
        final response = await http.post(
          Uri.parse('$baseUrl/hospital/registrarHospital'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'clues': clues, // Enviar el CLUES obtenido
            'nombre': _nameController
                .text, // Nombre del hospital que se ingresa en la UI
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hospital registrado exitosamente.'),
            ),
          );
          Navigator.pushNamed(context, '/adminHomeScreen');
        } else {
          throw Exception(
              'Error en la respuesta del servidor: ${response.statusCode}');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró un registro de CLUES válido.'),
          ),
        );
      }
    } catch (e) {
      print('Error al registrar el hospital: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar el hospital: $e'),
        ),
      );
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
}
