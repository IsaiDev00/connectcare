import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminStartScreen extends StatefulWidget {
  const AdminStartScreen({super.key});

  @override
  _AdminStartScreen createState() => _AdminStartScreen();
}

class _AdminStartScreen extends State<AdminStartScreen> {
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
        title: const Text('Iniciar configuracion'),
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
                    'Error loading the hospital name',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  );
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Text(
                    'Hospital not found',
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
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  );
                }
              },
            ),
            const SizedBox(height: 40),
            Text(
              "It seems that you haven't done the initial configuration of your hospital",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Press Start! to start the hospital configuration",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/addFloorsScreen');
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text(
                  'Start!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
