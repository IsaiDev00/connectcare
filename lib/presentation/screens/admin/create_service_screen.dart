import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateServiceScreen extends StatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  _CreateServiceScreenState createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> floors = [];
  final TextEditingController nameController = TextEditingController();
  String? selectedFloor;
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  @override
  void initState() {
    super.initState();
    _fetchFloorsFromDatabase(); // Llama a la función para obtener los datos al iniciar
  }

  Future<void> _fetchFloorsFromDatabase() async {
    final clues = await _sharedPreferencesService.getClues();
    try {
      final response = await http.get(Uri.parse('$baseUrl/piso/clues/$clues'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          floors = data
              .map((item) => {
                    'name': 'Floor ${item['numero_piso']}',
                    'id': item['id_piso']
                  })
              .toList();
        });
      } else {
        throw Exception('Error al cargar los datos');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> createService(String nombre, String idPiso) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/servicio/'), // URL de tu API
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombre,
          'id_piso': int.parse(idPiso), // Convertir idPiso a entero
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service registered successfully')),
        );
        Navigator.pushNamed(context, '/manageServiceScreen');
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('A service with the same name already exists.')),
        );
      } else {
        throw Exception('Failed to create service');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error registering service')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create service"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:
              brightness == Brightness.dark ? Colors.transparent : Colors.white,
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: brightness == Brightness.dark
              ? Brightness.dark
              : Brightness.light,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),

                // NOMBRE
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name of the service",
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a name for the service";
                    } else if (value.length > 25) {
                      return 'Please enter a shorter name, less than 26 char';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // PISO
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Select Floor",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedFloor,
                  items: floors.map((floor) {
                    return DropdownMenuItem<String>(
                      value: floor['id'].toString(),
                      child: Text(
                        floor['name'],
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFloor = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select a floor";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // GUARDAR
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        selectedFloor != null) {
                      createService(nameController.text, selectedFloor!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please complete all required fields')),
                      );
                    }
                  },
                  child: const Text("Register service"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
