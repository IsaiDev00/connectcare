import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class WifiCredentialsScreen extends StatefulWidget {
  const WifiCredentialsScreen({super.key});

  @override
  _WifiCredentialsScreen createState() => _WifiCredentialsScreen();
}

class _WifiCredentialsScreen extends State<WifiCredentialsScreen> {
  static const platform = MethodChannel('com.tu_paquete/nfc');
  String _status = "Acerque una tarjeta NFC para interactuar...";
  final _formKey = GlobalKey<FormState>();

  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  final TextEditingController _ssid = TextEditingController();
  final TextEditingController _password = TextEditingController();
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> rooms = [];
  List<Map<String, dynamic>> beds = [];

  String? _selectedArea;
  String? _selectedRoom;
  String? _selectedBed;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _fetchServices();
  }

  Future<void> _initializeData() async {
    setState(() {});
  }

  Future<void> _fetchServices() async {
    try {
      final clues = await _sharedPreferencesService.getClues();
      final response = await http.get(Uri.parse('$baseUrl/servicio/$clues'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          services = data
              .map((item) => {
                    'id': item['id_servicio'],
                    'service_name': item['nombre_servicio']
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load services');
      }
    } catch (e) {
      print('Error fetching services: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading services: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchRooms(String serviceId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/sala/sala_servicio/$serviceId'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          rooms = data
              .map((item) =>
                  {'id': item['id_sala'], 'name': item['nombre_sala']})
              .toList();
        });
      } else {
        throw Exception('Failed to load rooms');
      }
    } catch (e) {
      print('Error fetching rooms: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading rooms: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchBeds(String roomId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/cama/camas_sala/$roomId'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          beds = data
              .map((item) => {
                    'id': item['id_cama'],
                    'name':
                        'Bed ${item['numero_cama']} - Type: ${item['tipo']}',
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load beds');
      }
    } catch (e) {
      print('Error fetching beds: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading beds: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _validateText(String? value, String fieldName, int maxLength) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }

  String? _validateSelection(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  List<String> splitIntoChunks(String data, int chunkSize) {
    List<String> chunks = [];
    for (int i = 0; i < data.length; i += chunkSize) {
      int end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
      chunks.add(data.substring(i, end));
    }
    return chunks;
  }

  Future<void> _writeToNFC() async {
    if (_formKey.currentState!.validate() && _selectedBed != null) {
      // Quitamos espacios en SSID y password
      final ssidNoSpaces = _ssid.text.replaceAll(' ', '');
      final passwordNoSpaces = _password.text.replaceAll(' ', '');

      final wifiData = {
        'ssid': ssidNoSpaces,
        'password': passwordNoSpaces,
        'bed_id': _selectedBed,
      };

      // Construimos la cadena para escribir
      final dataString =
          'ssid:${wifiData['ssid']}|pw:${wifiData['password']}|bed:${wifiData['bed_id']}|e';

      // Cortamos en chunks de 16 bytes
      List<String> chunks = splitIntoChunks(dataString, 16);

      // Preparamos la lista de bloques a escribir en una sola pasada
      List<Map<String, String>> blocksToWrite = [];
      int block = 8;

      for (String chunk in chunks) {
        // Saltar bloques tráiler (cada 4to bloque en MifareClassic)
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
        // Llamamos a la nueva invocación de método que escribe múltiples bloques a la vez
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
          // A diferencia de antes, NO limpiamos los campos, para permitir reprogramar
          // sin tener que volver a introducir todo.
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
        title: Text('Wifi Credentials'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 30),
              Text(
                "Please enter the wifi credentials",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _status,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(onPressed: readNFC, child: Text("Leer nfc")),
              SizedBox(height: 10),
              TextFormField(
                controller: _ssid,
                decoration: InputDecoration(
                  labelText: 'SSID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validateText(value, 'SSID', 100),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: _password,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validateText(value, 'Password', 100),
              ),
              SizedBox(height: 30),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Area',
                  border: OutlineInputBorder(),
                ),
                value: _selectedArea,
                items: services
                    .map((service) => DropdownMenuItem(
                          value: service['id'].toString(),
                          child: Text(
                            service['service_name'],
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedArea = value;
                    _selectedRoom = null;
                    _selectedBed = null;
                    rooms = [];
                    beds = [];
                    _fetchRooms(value!);
                  });
                },
                validator: (value) => _validateSelection(value, 'Area'),
              ),
              SizedBox(height: 20),
              if (rooms.isNotEmpty)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Room',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedRoom,
                  items: rooms
                      .map((room) => DropdownMenuItem(
                            value: room['id'].toString(),
                            child: Text(
                              room['name'],
                              style: TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRoom = value;
                      _selectedBed = null;
                      beds = [];
                      _fetchBeds(value!);
                    });
                  },
                  validator: (value) => _validateSelection(value, 'Room'),
                ),
              SizedBox(height: 20),
              if (beds.isNotEmpty)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Bed',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedBed,
                  items: beds
                      .map((bed) => DropdownMenuItem(
                            value: bed['id'].toString(),
                            child: Text(
                              bed['name'],
                              style: TextStyle(
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBed = value;
                    });
                  },
                  validator: (value) => _validateSelection(value, "Bed"),
                ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _writeToNFC,
                child: Text('Write to NFC'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
