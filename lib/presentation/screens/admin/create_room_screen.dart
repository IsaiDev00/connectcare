import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:intl/intl.dart'; // Importa intl para formateo de fechas

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  CreateRoomScreenState createState() => CreateRoomScreenState();
}

class CreateRoomScreenState extends State<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  bool is24_7 = true;
  bool hasVisitingHours = false;

  List<Map<String, dynamic>> services = [];
  String? selectedServiceId;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController startVisitingController = TextEditingController();
  final TextEditingController endVisitingController = TextEditingController();
  final TextEditingController maxVisitsController = TextEditingController();
  final TextEditingController maxBedsController = TextEditingController();

  final Map<String, TextEditingController> startControllers = {
    'Monday': TextEditingController(),
    'Tuesday': TextEditingController(),
    'Wednesday': TextEditingController(),
    'Thursday': TextEditingController(),
    'Friday': TextEditingController(),
    'Saturday': TextEditingController(),
    'Sunday': TextEditingController(),
  };

  final Map<String, TextEditingController> endControllers = {
    'Monday': TextEditingController(),
    'Tuesday': TextEditingController(),
    'Wednesday': TextEditingController(),
    'Thursday': TextEditingController(),
    'Friday': TextEditingController(),
    'Saturday': TextEditingController(),
    'Sunday': TextEditingController(),
  };

  // Indicates if the room is closed on a specific day
  final Map<String, bool> isClosed = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();
  // Variable para manejar el estado de carga
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchServices(); // Fetch services on initialization
  }

  Future<void> _fetchServices() async {
    final clues = await _sharedPreferencesService.getClues();
    try {
      final response = await http.get(Uri.parse('$baseUrl/servicio/$clues'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          services = data
              .map((item) =>
                  {'id': item['id_servicio'], 'name': item['nombre_servicio']})
              .toList();
        });
      } else {
        throw Exception('Failed to load services');
      }
    } catch (e) {
      print('Error fetching services: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar servicios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTime(String time) {
    try {
      // Remueve caracteres especiales o espacios no visibles
      time = time.replaceAll(RegExp(r'[\u202F\u00A0]'), '').trim();

      // Intenta parsear el formato en formato de 12 horas si detecta "AM" o "PM"
      DateTime parsedTime;
      if (time.contains(RegExp(r'AM|PM', caseSensitive: false))) {
        parsedTime = DateFormat.jm().parse(time);
      } else {
        // Asume que está en formato de 24 horas si no hay AM/PM
        parsedTime = DateFormat.Hms().parse(time);
      }

      // Devuelve en formato HH:mm:ss
      return DateFormat('HH:mm:ss').format(parsedTime);
    } catch (e) {
      print('Error formateando el tiempo: $e');
      return '00:00:00';
    }
  }

  Future<void> crearSalaConHorarios(
    String nombre,
    int numero,
    Map<String, TextEditingController> startControllers,
    Map<String, TextEditingController> endControllers,
    Map<String, bool> isClosed,
    TextEditingController maxBedsController,
    TextEditingController startVisitingController,
    TextEditingController endVisitingController,
    TextEditingController maxVisitsController,
    String idServicio,
  ) async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('$baseUrl/sala/crearSalaConHorarios');
      Map<String, Map<String, String?>> horarioAtencion = {};

      if (is24_7) {
        for (var day in startControllers.keys) {
          horarioAtencion[day] = {
            'hora_inicio': "00:00:00",
            'hora_fin': "00:00:00"
          };
        }
      } else {
        for (var day in startControllers.keys) {
          if (isClosed[day]!) {
            horarioAtencion[day] = {'hora_inicio': null, 'hora_fin': null};
          } else {
            horarioAtencion[day] = {
              'hora_inicio': startControllers[day]!.text.isNotEmpty
                  ? _formatTime(startControllers[day]!.text)
                  : null,
              'hora_fin': endControllers[day]!.text.isNotEmpty
                  ? _formatTime(endControllers[day]!.text)
                  : null,
            };
          }
        }
      }

      Map<String, dynamic> payload = {
        'nombre': nombre,
        'numero': numero,
        'id_servicio': int.parse(idServicio),
        'horarioAtencion': horarioAtencion,
        'maxBeds': int.parse(maxBedsController.text),
      };

      if (hasVisitingHours) {
        if (startVisitingController.text.isNotEmpty &&
            endVisitingController.text.isNotEmpty &&
            maxVisitsController.text.isNotEmpty) {
          payload['horarioVisita'] = {
            'inicio': _formatTime(startVisitingController.text),
            'fin': _formatTime(endVisitingController.text),
            'visitantes': int.parse(maxVisitsController.text),
          };
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please complete all visiting hours fields')),
          );
          return;
        }
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('A room with the same name and number already exists.')),
        );
      } else {
        _responseCreateRoom(response);
      }
    } catch (e) {
      print('Error creating the room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating the room: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _responseCreateRoom(http.Response response) {
    if (response.statusCode == 201) {
      showCustomSnackBar(context, 'Sala creada con éxito');
      Navigator.pop(context, 'refresh');
    } else {
      showCustomSnackBar(context, 'Error al crear sala');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  void dispose() {
    startControllers.forEach((_, controller) => controller.dispose());
    endControllers.forEach((_, controller) => controller.dispose());
    nameController.dispose();
    numberController.dispose();
    startVisitingController.dispose();
    endVisitingController.dispose();
    maxVisitsController.dispose();
    maxBedsController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(TextEditingController controller) async {
    if (!mounted) return;
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && mounted) {
      final now = DateTime.now();
      // Formatea a HH:mm:ss
      final formattedTime = DateFormat('HH:mm:ss').format(
        DateTime(
            now.year, now.month, now.day, pickedTime.hour, pickedTime.minute),
      );
      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  bool _validateDays() {
    // If not 24/7, verify each day has valid hours or is closed
    if (!is24_7) {
      for (var day in startControllers.keys) {
        if (!isClosed[day]!) {
          if (startControllers[day]!.text.isEmpty ||
              endControllers[day]!.text.isEmpty) {
            return false;
          }
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: Text("Create Room".tr()),
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
          ? const Center(
              child: CircularProgressIndicator(),
            )
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

                      // NAME OF THE ROOM
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Name of the room",
                          border: OutlineInputBorder(),
                        ),
                        autofocus: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name for the room'.tr();
                          } else if (value.length > 30) {
                            return 'Please enter a shorter name, less than 31 char'.tr();
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // NUMBER OF THE ROOM
                      TextFormField(
                        controller: numberController,
                        decoration: const InputDecoration(
                          labelText: "Number of the room",
                          border: OutlineInputBorder(),
                        ),
                        autofocus: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a number for the room'.tr();
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      // OPENING HOURS
                      Text("Opening hours".tr()),
                      const SizedBox(height: 5),

                      SizedBox(
                        width: 200,
                        child: CheckboxListTile(
                          title: Text("24/7"),
                          value: is24_7,
                          onChanged: (value) {
                            setState(() {
                              is24_7 = value ?? false;
                              if (is24_7) {
                                // Clear manual entries if 24/7 is selected
                                startControllers.forEach(
                                    (_, controller) => controller.clear());
                                endControllers.forEach(
                                    (_, controller) => controller.clear());
                                // Ensure all days are open
                                isClosed.updateAll((key, value) => false);
                              }
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 5),

                      Visibility(
                        visible: is24_7,
                        child: Column(
                          children: [
                            Text(
                              "When 24/7 is selected, the room is open all day, every day.",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),

                      Visibility(
                        visible: !is24_7,
                        child: Column(
                          children: startControllers.entries.map((entry) {
                            String day = entry.key;
                            TextEditingController startController = entry.value;
                            TextEditingController endController =
                                endControllers[day]!;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Text(day),
                                  ),
                                  const SizedBox(width: 40),
                                  SizedBox(
                                    width: 100,
                                    child: CheckboxListTile(
                                      value: isClosed[day],
                                      onChanged: (value) {
                                        setState(() {
                                          isClosed[day] = value ?? false;
                                          if (isClosed[day]!) {
                                            startController.clear();
                                            endController.clear();
                                          }
                                        });
                                      },
                                      title: Text("Closed".tr()),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  SizedBox(
                                    width: 100,
                                    child: TextFormField(
                                      controller: startController,
                                      readOnly: true,
                                      enabled: !isClosed[day]!,
                                      decoration: const InputDecoration(
                                        labelText: "Start time",
                                      ),
                                      onTap: () => _selectTime(startController),
                                      validator: (value) {
                                        if (!isClosed[day]! &&
                                            (value == null || value.isEmpty)) {
                                          return 'Required'.tr();
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 100,
                                    child: TextFormField(
                                      controller: endController,
                                      readOnly: true,
                                      enabled: !isClosed[day]!,
                                      decoration: const InputDecoration(
                                        labelText: "End time",
                                      ),
                                      onTap: () => _selectTime(endController),
                                      validator: (value) {
                                        if (!isClosed[day]! &&
                                            (value == null || value.isEmpty)) {
                                          return 'Required'.tr();
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // VISITING HOURS
                      SizedBox(
                        width: 200,
                        child: CheckboxListTile(
                          title: Text("Add Visiting Hours".tr()),
                          value: hasVisitingHours,
                          onChanged: (value) {
                            setState(() {
                              hasVisitingHours = value ?? false;
                              if (!hasVisitingHours) {
                                startVisitingController.clear();
                                endVisitingController.clear();
                                maxVisitsController.clear();
                              }
                            });
                          },
                        ),
                      ),

                      Visibility(
                        visible: hasVisitingHours,
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Text("Visiting hours".tr()),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: TextFormField(
                                    controller: startVisitingController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: "Start visiting time",
                                    ),
                                    onTap: () =>
                                        _selectTime(startVisitingController),
                                    validator: (value) {
                                      if (hasVisitingHours &&
                                          (value == null || value.isEmpty)) {
                                        return 'Required'.tr();
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 200,
                                  child: TextFormField(
                                    controller: endVisitingController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: "End visiting time",
                                    ),
                                    onTap: () =>
                                        _selectTime(endVisitingController),
                                    validator: (value) {
                                      if (hasVisitingHours &&
                                          (value == null || value.isEmpty)) {
                                        return 'Required'.tr();
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // MAX NUMBER OF VISITORS
                            TextFormField(
                              controller: maxVisitsController,
                              decoration: const InputDecoration(
                                labelText: "Max number of visitors",
                                border: OutlineInputBorder(),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (hasVisitingHours) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a number of visitors'.tr();
                                  }
                                  int? num = int.tryParse(value);
                                  if (num == null) {
                                    return 'Invalid number'.tr();
                                  }
                                  if (num > 20) {
                                    return 'Please enter a number below 20 visitors'.tr();
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // MAX NUMBER OF BEDS/INCUBATORS/CRIBS
                      TextFormField(
                        controller: maxBedsController,
                        decoration: const InputDecoration(
                          labelText: "Max number of beds/incubators/cribs",
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a max number of beds/incubators/cribs'.tr();
                          }
                          int? num = int.tryParse(value);
                          if (num == null) {
                            return 'Invalid number'.tr();
                          }
                          if (num > 50) {
                            return 'Please enter a number below 50 beds/incubators/cribs'.tr();
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      // Service Selection
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Select Service",
                          border: OutlineInputBorder(),
                        ),
                        value: selectedServiceId,
                        items: services.map((service) {
                          return DropdownMenuItem<String>(
                            value: service['id'].toString(),
                            child: Text(
                              service['name'],
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedServiceId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select a service";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 40),

                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() &&
                              _validateDays()) {
                            crearSalaConHorarios(
                              nameController.text,
                              int.parse(numberController.text),
                              startControllers,
                              endControllers,
                              isClosed,
                              maxBedsController,
                              startVisitingController,
                              endVisitingController,
                              maxVisitsController,
                              selectedServiceId!,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please enter valid times for all open days')),
                            );
                          }
                        },
                        child: Text("Register Room".tr()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
