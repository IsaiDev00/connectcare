import 'dart:convert';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class CreateProcedureScreen extends StatefulWidget {
  const CreateProcedureScreen({super.key});

  @override
  State<CreateProcedureScreen> createState() => _CreateProcedureScreenState();
}

class _CreateProcedureScreenState extends State<CreateProcedureScreen> {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> salas = [];
  List<String> formattedSalas = [];

  // Controladores para los campos de texto
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController startVisitingController = TextEditingController();

  // Se reemplaza el dropdown por:
  final TextEditingController salaSearchController = TextEditingController();
  String searchQuery = '';
  String? salaController; // Aquí almacenaremos la sala elegida

  final TextEditingController cantNurseController = TextEditingController();
  final TextEditingController cantDoctorController = TextEditingController();

  Future<void> fetchSalas() async {
    final clues = await _sharedPreferencesService.getClues();
    final response = await http.get(Uri.parse('$baseUrl/sala/$clues'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        salas = data
            .map((sala) => {
                  'nombre': sala['nombre_sala'],
                  'numero': sala['numero_sala'],
                })
            .toList();
        // Generar formattedSalas a partir de salas ya llenado
        formattedSalas = salas.map((sala) {
          return '${sala['nombre']} No. ${sala['numero']}';
        }).toList();
      });
    } else {
      throw Exception('Error al obtener los registros de Sala');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSalas();
  }

  // Getter para filtrar salas según el texto escrito
  List<String> get searchResults {
    if (searchQuery.isEmpty) {
      return [];
    }
    return formattedSalas
        .where((s) => s.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> crearProcedimiento(
    String nombre,
    String descripcion,
    String salaNombreNumero,
    int noEnfermeros,
    int noDoctores,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/procedimiento/');
      final procedimientoPayload = {
        'nombre': nombre,
        'descripcion': descripcion,
        'cantidad_enfermeros': noEnfermeros,
        'cantidad_medicos': noDoctores,
      };

      // Crear el procedimiento en la tabla procedimiento
      final procedimientoResponse = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(procedimientoPayload),
      );

      if (procedimientoResponse.statusCode == 201) {
        // Procedimiento creado exitosamente

        // Separar el nombre y el número de sala
        final splitSala = salaNombreNumero.split(' No. ');
        final salaNombre = splitSala[0]; // Nombre de la sala
        final salaNumero = splitSala[1]; // Número de la sala

        // Solicitar el ID de la sala basado en el nombre y el número
        final salaUrl =
            Uri.parse('$baseUrl/sala/nombre/$salaNombre/numero/$salaNumero');
        final salaResponse = await http.get(
          salaUrl,
          headers: {'Content-Type': 'application/json'},
        );

        if (salaResponse.statusCode == 200) {
          // Obtener el ID de la sala
          final salaData = json.decode(salaResponse.body);
          final int salaId = salaData['id_sala'];

          // Obtener el ID del procedimiento recién creado
          final procedimientoData = json.decode(procedimientoResponse.body);
          final int procedimientoId = procedimientoData['id_procedimiento'];

          // Crear el registro en sala_procedimiento
          final salaProcedimientoUrl =
              Uri.parse('$baseUrl/sala_procedimiento/');
          final salaProcedimientoPayload = {
            'numero_sala': salaId,
            'id_procedimiento': procedimientoId,
          };

          final salaProcedimientoResponse = await http.post(
            salaProcedimientoUrl,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(salaProcedimientoPayload),
          );

          if (salaProcedimientoResponse.statusCode == 201) {
            _responseCreateProcedure();
          } else {
            throw Exception('Error linking procedure with room');
          }
        } else {
          throw Exception('Error retrieving room ID');
        }
      } else if (procedimientoResponse.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('A procedure with the same name already exists.')),
        );
      } else {
        throw Exception('Failed to create procedure');
      }
    } catch (e) {
      _responseError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: Text("Create procedure".tr()),
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
                    labelText: "Name of the procedure",
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name for the procedure'.tr();
                    } else if (value.length > 25) {
                      return 'Please enter a shorter name, less than 26 char'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // DESCRIPCION
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: "Description of the procedure",
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description for the procedure'.tr();
                    } else if (value.length > 500) {
                      return 'Please enter a shorter description, less than 501 char'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // SALA (BUSCADOR)
                TextFormField(
                  controller: salaSearchController,
                  decoration: const InputDecoration(
                    labelText: "Search for room",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),

                // Lista de resultados
                if (searchResults.isNotEmpty)
                  Container(
                    // Para controlar la altura del listado desplegado
                    constraints: const BoxConstraints(maxHeight: 150),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final room = searchResults[index];
                        return ListTile(
                          title: Text(room),
                          onTap: () {
                            setState(() {
                              salaController = room;
                              salaSearchController.text = room;
                              // Limpiamos el query para esconder la lista
                              searchQuery = '';
                            });
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 15),

                // CANTIDAD ENFERMEROS
                TextFormField(
                  controller: cantNurseController,
                  decoration: const InputDecoration(
                    labelText: "The needed amount of nurses in this procedure",
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount of nurses'.tr();
                    } else if (int.parse(value) > 25) {
                      return 'Please enter a number less or equal than 25'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // CANTIDAD DOCTORES
                TextFormField(
                  controller: cantDoctorController,
                  decoration: const InputDecoration(
                    labelText: "The needed amount of doctors in this procedure",
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount of doctors'.tr();
                    } else if (int.parse(value) > 25) {
                      return 'Please enter a number less or equal than 25'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // BOTON ENVIAR
                ElevatedButton(
                  onPressed: () {
                    // Validamos formulario y sala elegida
                    if (_formKey.currentState!.validate()) {
                      if (salaController == null || salaController!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a room from the list'),
                          ),
                        );
                        return;
                      }

                      crearProcedimiento(
                        nameController.text,
                        descController.text,
                        salaController!,
                        int.parse(cantNurseController.text),
                        int.parse(cantDoctorController.text),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please don\'t leave any fields blank'),
                        ),
                      );
                    }
                  },
                  child: Text("Create procedure".tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _responseCreateProcedure() {
    showCustomSnackBar(
      context,
      "Procedimiento y enlace con sala creados exitosamente",
    );
    // Aquí en lugar de pushReplacementNamed, devolvemos 'refresh'.
    Navigator.pop(context, 'refresh');
  }

  void _responseError(e) {
    showCustomSnackBar(context, e.toString());
  }
}
