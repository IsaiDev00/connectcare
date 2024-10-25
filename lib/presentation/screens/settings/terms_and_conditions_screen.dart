import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart'; // Importa la constante baseUrl

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  _TermsAndConditionsScreenState createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  String _termsAndConditions = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchTermsAndConditions();
  }

  Future<void> _fetchTermsAndConditions() async {
    final url =
        '$baseUrl/documents/terms'; // Usa la constante baseUrl para construir la URL
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _termsAndConditions = data['content'];
          _loading = false;
        });
      } else {
        setState(() {
          _termsAndConditions = 'Error al cargar los Términos y Condiciones';
          _loading = false;
        });
      }
    } catch (error) {
      setState(() {
        _termsAndConditions =
            'Error de conexión: No se pudo cargar el contenido.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Términos y Condiciones'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _termsAndConditions,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
    );
  }
}
