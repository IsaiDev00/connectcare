import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

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
  static const platform = MethodChannel('com.tu_paquete/nfc');
  String _status = "";

  String? idMedico;
  List<dynamic> _patientsList = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getID();
  }

  Future<void> _getID() async {
    try {
      final String idPersonal = widget.user;
      final url = Uri.parse('$baseUrl/medico/id/$idPersonal');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            idMedico = data[0]['id_medico'].toString();
          });
          _fetchpatients();
        }
      } else if (response.statusCode == 404) {
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
      final url = Uri.parse('$baseUrl/medico/medicoPaciente/$idMedico');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _patientsList = data;
          _errorMessage = '';
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _patientsList = [];
          _errorMessage = 'El médico no tiene pacientes aún';
        });
      } else {
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

  List<String> splitIntoChunks(String text, int chunkSize) {
    List<String> chunks = [];
    for (int i = 0; i < text.length; i += chunkSize) {
      chunks.add(text.substring(
          i, i + chunkSize > text.length ? text.length : i + chunkSize));
    }
    return chunks;
  }

  Future<void> _writeNssToCard(String nss) async {
    final dataString = 'nss:$nss|e';
    List<String> chunks = splitIntoChunks(dataString, 16);
    List<Map<String, String>> blocksToWrite = [];
    int block = 8;
    for (String chunk in chunks) {
      while (block % 4 == 3) {
        block++;
      }
      blocksToWrite.add({
        'block': block.toString(),
        'data': chunk,
      });
      block++;
    }
    try {
      final bool allSuccess = await platform.invokeMethod(
        'writeMultipleNFCBlocks',
        {'writes': blocksToWrite},
      );
      if (allSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Información escrita exitosamente en la tarjeta!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al escribir en la tarjeta.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al escribir en la tarjeta: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> readNFC() async {
    setState(() {
      _status = "Esperando tarjeta NFC para leer...";
    });
    try {
      final String? rawData = await platform.invokeMethod('readAllNFCBlocks');
      if (rawData != null && rawData.isNotEmpty) {
        String processed = rawData;
        int endIndex = processed.indexOf('|e');
        if (endIndex != -1) {
          processed = processed.substring(0, endIndex);
        }
        setState(() {
          _status = "Texto leído: $processed";
        });
      } else {
        setState(() {
          _status = "No se pudo leer ningún dato de la tarjeta.";
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _status = "Error al leer la tarjeta: ${e.message}";
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
              Center(child: Text("Please choose one patient")),
              SizedBox(height: 20),
              ElevatedButton(onPressed: readNFC, child: Text("READ NFC")),
              SizedBox(height: 10),
              Text(_status),
              SizedBox(height: 10),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
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
                      title: Text(nombreCompleto),
                      subtitle: Text('NSS: $nss'),
                      onTap: () async {
                        await _writeNssToCard(nss);
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
