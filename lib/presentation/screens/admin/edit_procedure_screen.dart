import 'dart:convert';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class EditProcedureScreen extends StatefulWidget {
  final int procedureId;

  const EditProcedureScreen({super.key, required this.procedureId});

  @override
  State<EditProcedureScreen> createState() => _EditProcedureScreenState();
}

class _EditProcedureScreenState extends State<EditProcedureScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> salas = [];
  List<String> formattedSalas = [];

  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  String? salaController;
  final TextEditingController cantNurseController = TextEditingController();
  final TextEditingController cantDoctorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSalas();
    fetchProcedureDetails();
  }

  Future<void> fetchSalas() async {
    final response = await http.get(Uri.parse('$baseUrl/sala/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        salas = data
            .map((sala) => {
                  'id_sala': sala['id_sala'],
                  'nombre': sala['nombre'],
                  'numero': sala['numero'],
                })
            .toList();
        formattedSalas = salas.map((sala) {
          return '${sala['nombre']} No. ${sala['numero']}';
        }).toList();
      });
    } else {
      throw Exception('Error al obtener los registros de Sala');
    }
  }

  Future<void> fetchProcedureDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/procedimiento//${widget.procedureId}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          nameController.text = data['nombre'] ?? '';
          descController.text = data['descripcion'] ?? '';
          cantNurseController.text = data['cantidad_enfermeros'].toString();
          cantDoctorController.text = data['cantidad_medicos'].toString();

          // Obtener la sala vinculada al procedimiento
          fetchLinkedSala();
        });
      } else {
        throw Exception('Error al obtener los detalles del procedimiento');
      }
    } catch (e) {
      print('Error fetching procedure details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching procedure details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchLinkedSala() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/sala_procedimiento/procedimiento/${widget.procedureId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data['sala'] != null) {
          final sala = data['sala'];
          final salaNombre = sala['nombre'];
          final salaNumero = sala['numero'];
          setState(() {
            salaController = '${salaNombre} No. ${salaNumero}';
          });
        }
      } else {
        throw Exception('Error fetching linked room');
      }
    } catch (e) {
      print('Error fetching linked room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching linked room: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateProcedure(
    String nombre,
    String descripcion,
    String salaNombreNumero,
    int noEnfermeros,
    int noDoctores,
  ) async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('$baseUrl/procedimiento/procedimiento/${widget.procedureId}');
      final procedimientoPayload = {
        'nombre': nombre,
        'descripcion': descripcion,
        'cantidad_enfermeros': noEnfermeros,
        'cantidad_medicos': noDoctores,
      };

      // Actualizar el procedimiento
      final procedimientoResponse = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(procedimientoPayload),
      );

      if (procedimientoResponse.statusCode == 200) {
        // Procedimiento actualizado exitosamente

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

          // Actualizar el registro en sala_procedimiento
          final salaProcedimientoUrl = Uri.parse(
              '$baseUrl/sala_procedimiento/procedimiento/${widget.procedureId}');
          final salaProcedimientoPayload = {
            'numero_sala': salaId,
            'id_procedimiento': widget.procedureId,
          };

          final salaProcedimientoResponse = await http.put(
            salaProcedimientoUrl,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(salaProcedimientoPayload),
          );

          if (salaProcedimientoResponse.statusCode == 200) {
            _responseUpdateProcedure();
          } else if (salaProcedimientoResponse.statusCode == 404) {
            // Si no existe el vínculo, crearlo
            final newSalaProcedimientoUrl =
                Uri.parse('$baseUrl/sala_procedimiento/');
            final newSalaProcedimientoResponse = await http.post(
              newSalaProcedimientoUrl,
              headers: {'Content-Type': 'application/json'},
              body: json.encode(salaProcedimientoPayload),
            );

            if (newSalaProcedimientoResponse.statusCode == 201) {
              _responseUpdateProcedure();
            } else {
              throw Exception('Error linking procedure with room');
            }
          } else {
            throw Exception('Error updating link between procedure and room');
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
        throw Exception('Failed to update procedure');
      }
    } catch (e) {
      _responseError(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _responseUpdateProcedure() {
    showCustomSnackBar(context, "Procedimiento actualizado exitosamente");
    Navigator.pushNamed(context, '/manageProcedureScreen');
  }

  void _responseError(e) {
    showCustomSnackBar(context, e.toString());
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Procedure"),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                            return 'Please enter a name for the procedure';
                          } else if (value.length > 25) {
                            return 'Please enter a shorter name, less than 26 char';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // DESCRIPCIÓN
                      TextFormField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: "Description of the procedure",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                        autofocus: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description for the procedure';
                          } else if (value.length > 500) {
                            return 'Please enter a shorter description, less than 501 char';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // SALA (LISTA)
                      DropdownButtonFormField<String>(
                        value: salaController,
                        decoration: const InputDecoration(
                          labelText: 'Room',
                          border: OutlineInputBorder(),
                        ),
                        items: formattedSalas.map((String sala) {
                          return DropdownMenuItem<String>(
                            value: sala,
                            child: Text(
                              sala,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            salaController = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a room';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // CANTIDAD ENFERMEROS
                      TextFormField(
                        controller: cantNurseController,
                        decoration: const InputDecoration(
                          labelText:
                              "The needed amount of nurses in this procedure",
                          border: OutlineInputBorder(),
                        ),
                        autofocus: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount of nurses';
                          } else if (int.parse(value) > 25) {
                            return 'Please enter a number less or equal than 25';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // CANTIDAD DOCTORES
                      TextFormField(
                        controller: cantDoctorController,
                        decoration: const InputDecoration(
                          labelText:
                              "The needed amount of doctors in this procedure",
                          border: OutlineInputBorder(),
                        ),
                        autofocus: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount of doctors';
                          } else if (int.parse(value) > 25) {
                            return 'Please enter a number less or equal than 25';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // BOTÓN GUARDAR
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            updateProcedure(
                              nameController.text,
                              descController.text,
                              salaController!,
                              int.parse(cantNurseController.text),
                              int.parse(cantDoctorController.text),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please don\'t leave any fields blank'),
                              ),
                            );
                          }
                        },
                        child: const Text("Save Changes"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
