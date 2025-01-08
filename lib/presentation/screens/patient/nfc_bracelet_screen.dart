import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NfcBraceletScreen extends StatefulWidget {
  final String user;
  const NfcBraceletScreen({super.key, required this.user});

  @override
  _NfcBraceletScreen createState() => _NfcBraceletScreen();
}

class _NfcBraceletScreen extends State<NfcBraceletScreen> {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();
  final _formKey = GlobalKey<FormState>();

  String? idMedico;

  List<dynamic> _patientsList = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getID();
    _fetchpatients();
  }

  Future<void> _getID() async {
    try {
      // 'widget.user' es el idPersonal
      final String idPersonal = widget.user;

      final url = Uri.parse('$baseUrl/medico/id/$idPersonal');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // La respuesta será un array, ej: [ { "id_medico": 7 } ]
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          // Accedemos al primer elemento y extraemos 'id_medico'
          setState(() {
            idMedico = data[0]['id_medico'];
          });
        }
      } else if (response.statusCode == 404) {
        // Manejo de "El médico no existe"
        debugPrint('El médico con idPersonal: $idPersonal no existe');
      } else {
        debugPrint('Error inesperado. Código: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Ha ocurrido un error al obtener el idMedico: $e');
    }
  }

  Future<void> _fetchpatients() async {
    try {
      // Ajusta la URL a la de tu servidor
      final url = Uri.parse('$baseUrl/medico/medicoPaciente/$idMedico');

      // Si usas http de 'package:http/http.dart'
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decodificamos la respuesta (debe ser un JSON array con los pacientes)
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          _patientsList = data;
          _errorMessage = ''; // Reseteamos cualquier error anterior
        });
      } else if (response.statusCode == 404) {
        // En caso de que no tenga pacientes
        setState(() {
          _patientsList = [];
          _errorMessage = 'El médico no tiene pacientes aún';
        });
      } else {
        // Otros errores
        setState(() {
          _errorMessage =
              'Error al obtener los pacientes. Código: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ha ocurrido un error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bracelet NFC'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 30),
              Text("Please choose one patient"),

              // Si hay un mensaje de error o advertencia
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              // Si la lista _patientsList NO está vacía, mostramos ListView (o Column)
              if (_patientsList.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _patientsList.length,
                  itemBuilder: (context, index) {
                    final patient = _patientsList[index];
                    final nss = patient['nss_paciente'].toString();
                    final nombreCompleto = patient['nombre_completo'] ?? '';

                    return ListTile(
                      title: Text('$nombreCompleto'),
                      subtitle: Text('NSS: $nss'),
                      onTap: () {
                        // Acción al seleccionar un paciente, si la hubiera
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
