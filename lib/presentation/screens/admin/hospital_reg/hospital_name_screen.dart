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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  bool isButtonEnabled = false;

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
      final cluesData = await _sharedPreferencesService.getCluesCode();
      final userId = await _sharedPreferencesService.getUserId();

      if (cluesData != null && userId != null) {
        final clues = cluesData;

        // Realiza la solicitud para registrar el hospital
        final response = await http.post(
          Uri.parse('$baseUrl/hospital/registrarHospital'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'clues': clues,
            'nombre': _nameController.text.trim(),
            'id_personal': userId,
          }),
        );

        if (response.statusCode == 409) {
          // El backend indica que el nombre ya está en uso
          showCustomSnackBar(context, 'El nombre del hospital ya está en uso.');
          return;
        }

        if (response.statusCode == 200) {
          // Registro exitoso
          _responseHospitalRegister(response);
        } else {
          // Manejo de otros errores
          throw Exception('Error al registrar el hospital: ${response.body}');
        }
      } else {
        String message = 'Faltan datos necesarios para registrar el hospital.';
        if (cluesData == null) {
          message = 'No se encontró un registro CLUES válido.';
        }
        if (userId == null) message = 'No se encontró un ID de usuario válido.';

        _validationsHospitalRegister(message);
      }
    } catch (e) {
      _responseError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Name'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Please add a name for the hospital. Be as clear as possible.\nE.g., IMSS Clinic 14',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter the hospital name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name for the hospital';
                  } else if (value.length > 25) {
                    return 'Please make it shorter, less than 26 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isButtonEnabled
                    ? () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _registerHospital();
                        }
                      }
                    : null,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _responseHospitalRegister(response) {
    if (response.statusCode == 201) {
      showCustomSnackBar(context, 'Hospital registered successfully');
      Navigator.pushNamed(context, '/adminStartScreen');
    } else {
      throw Exception(
          'Server response error: ${response.statusCode} - ${response.body}');
    }
  }

  void _validationsHospitalRegister(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _responseError(e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Hospital registration error: $e'),
      ),
    );
  }
}
