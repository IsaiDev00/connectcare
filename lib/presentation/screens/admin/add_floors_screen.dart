import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddFloorsScreen extends StatefulWidget {
  const AddFloorsScreen({super.key});

  @override
  _AddFloorsScreen createState() => _AddFloorsScreen();
}

class _AddFloorsScreen extends State<AddFloorsScreen> {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  final TextEditingController _floorsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _addFloors() async {
    final clues = await _sharedPreferencesService.getClues();
    if (_formKey.currentState!.validate()) {
      int numberOfFloors = int.parse(_floorsController.text.trim());

      try {
        for (int i = 1; i <= numberOfFloors; i++) {
          var url = Uri.parse('$baseUrl/piso/');
          var response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'numero_piso': i,
              'clues': clues,
            }),
          );

          if (response.statusCode != 201) {
            throw Exception('Error al agregar el piso $i');
          }
        }

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pisos agregados exitosamente')),
        );

        // Redirigir a otra pantalla después de agregar los pisos
        Navigator.pushReplacementNamed(context, '/shortTutorialScreen');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar pisos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Hospital Floors"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 70),
            // Mensaje inicial con estilo
            Center(
              child: const Text(
                "First of all, we need to know how many floors does your hospital have",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 50),

            // Formulario para ingresar el número de pisos
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _floorsController,
                    decoration: const InputDecoration(
                      labelText: "Number of floors",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of floors';
                      }
                      final n = int.tryParse(value);
                      if (n == null || n <= 0) {
                        return 'Please enter a valid positive number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 60),

                  // Botón para agregar pisos
                  ElevatedButton(
                    onPressed: _addFloors,
                    child: const Text("Add Floors"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
