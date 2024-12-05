import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart'; // Asegúrate de que esta importación es correcta

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  PrivacyPolicyScreenState createState() => PrivacyPolicyScreenState();
}

class PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String _privacyPolicy = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPrivacyPolicy();
  }

  Future<void> _fetchPrivacyPolicy() async {
    final url =
        '$baseUrl/documents/privacy'; // Usa la constante baseUrl para construir la URL
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _privacyPolicy = data['content'];
          _loading = false;
        });
      } else {
        setState(() {
          _privacyPolicy = 'Error al cargar la Política de Privacidad';
          _loading = false;
        });
      }
    } catch (error) {
      setState(() {
        _privacyPolicy = 'Error de conexión: No se pudo cargar el contenido.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Política de Privacidad'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _privacyPolicy,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
    );
  }
}
