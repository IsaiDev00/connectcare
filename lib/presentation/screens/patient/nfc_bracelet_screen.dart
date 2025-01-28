import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class NfcBraceletScreen extends StatefulWidget {
  const NfcBraceletScreen({super.key});

  @override
  _NfcBraceletScreenState createState() => _NfcBraceletScreenState();
}

class _NfcBraceletScreenState extends State<NfcBraceletScreen> {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  final _formKey = GlobalKey<FormState>();
  static const platform = MethodChannel('com.tu_paquete/nfc');

  String _status = "";

  // Aquí guardamos el idPersonal (común para médico o enfermero)
  String personalId = '';

  // Aquí guardaremos el rol que nos devuelva el backend ("medico" o "enfermero")
  String? specialistRole;

  // Este será el id_medico o id_enfermero
  String? specialistId;

  // Lista de pacientes
  List<dynamic> _patientsList = [];

  // Posibles errores en la UI
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getSpecialistRoleAndId();
  }

  /// Obtiene el rol (médico/enfermero) y el ID respectivo según el idPersonal
  Future<void> _getSpecialistRoleAndId() async {
    final data = await _sharedPreferencesService.getUserId();
    if (data != null) {
      setState(() {
        personalId = data;
      });
    }

    try {
      final url = Uri.parse('$baseUrl/samm/obtenerId/$personalId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Guardamos rol e id
        setState(() {
          specialistRole = responseData['rol'];
          specialistId = responseData['id'].toString();
        });

        // Ahora que ya sabemos su rol e id, buscamos sus pacientes
        _fetchPatients();
      } else if (response.statusCode == 404) {
        debugPrint(
          'No se encontró un médico o enfermero con idPersonal: $personalId',
        );
      } else {
        debugPrint('Error inesperado. Código: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Ha ocurrido un error al obtener el rol e id: $e');
    }
  }

  /// Busca la lista de pacientes para el rol actual (médico o enfermero)
  Future<void> _fetchPatients() async {
    if (specialistRole == null || specialistId == null) {
      // Si no tenemos rol o id aún, no hacemos nada
      return;
    }

    try {
      final url =
          Uri.parse('$baseUrl/samm/personalPaciente/$specialistRole/$specialistId');
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
          _errorMessage = 'Este $specialistRole no tiene pacientes aún';
        });
      } else {
        setState(() {
          _errorMessage =
              'Error al obtener los pacientes. Código: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Ha ocurrido un error: $e';
        });
      }
    }
  }

  /// Función auxiliar para partir en chunks de 16 bytes
  List<String> splitIntoChunks(String text, int chunkSize) {
    List<String> chunks = [];
    for (int i = 0; i < text.length; i += chunkSize) {
      chunks.add(
        text.substring(
            i, i + chunkSize > text.length ? text.length : i + chunkSize),
      );
    }
    return chunks;
  }

  /// Escribe el NSS en el brazalete NFC
  Future<void> _writeNssToCard(String nss) async {
    final dataString = 'nss:$nss|e';
    List<String> chunks = splitIntoChunks(dataString, 16);

    List<Map<String, String>> blocksToWrite = [];
    int block = 8; // Bloque inicial donde quieres empezar a escribir

    for (String chunk in chunks) {
      // Saltar bloques de control (ej: cada sector 3 es de control)
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
          const SnackBar(
            content: Text('¡Información escrita exitosamente en la tarjeta!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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

  /// Lee toda la información del brazalete NFC
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
        title: Text('Bracelet NFC'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 30),
              Center(child: Text("Please choose one patient").tr()),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: readNFC,
                child: Text("READ NFC".tr()),
              ),
              const SizedBox(height: 10),
              Text(_status),
              const SizedBox(height: 10),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (_patientsList.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
