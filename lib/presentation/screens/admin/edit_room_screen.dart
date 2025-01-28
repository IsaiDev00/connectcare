import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';

class EditRoomScreen extends StatefulWidget {
  final int roomId;

  const EditRoomScreen({super.key, required this.roomId});

  @override
  EditRoomScreenState createState() => EditRoomScreenState();
}

class EditRoomScreenState extends State<EditRoomScreen> {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();
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

  final Map<String, bool> isClosed = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  bool isLoading = false;

  // Mapeo de días en inglés a español
  final Map<String, String> dayTranslations = {
    'Monday': 'lunes',
    'Tuesday': 'martes',
    'Wednesday': 'miercoles',
    'Thursday': 'jueves',
    'Friday': 'viernes',
    'Saturday': 'sabado',
    'Sunday': 'domingo',
  };

  @override
  void initState() {
    super.initState();
    fetchRoomDetails();
    _fetchServices();
  }

  Future<void> fetchRoomDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('$baseUrl/sala/sala/${widget.roomId}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          print('$data');
          nameController.text = data['nombre_sala'];
          numberController.text = data['numero'].toString();
          selectedServiceId = data['id_servicio'].toString();
          maxBedsController.text = data['max_beds'].toString();

          // Recibimos si es 24/7 e info de visitas (si la API lo provee)
          is24_7 = data['is24_7'] ?? false;
          hasVisitingHours = data['hasVisitingHours'] ?? false;

          // Si hay horario de visita
          if (hasVisitingHours && data['horarioVisita'] != null) {
            startVisitingController.text = data['horarioVisita']['inicio'];
            endVisitingController.text = data['horarioVisita']['fin'];
            maxVisitsController.text =
                data['horarioVisita']['visitantes'].toString();
          }

          // Cargar horario de atención
          final horarioAtencion = data['horarioAtencion'] ?? {};

          startControllers.forEach((day, controller) {
            String dayInSpanish = dayTranslations[day]!;
            controller.text =
                horarioAtencion['${dayInSpanish}_hora_inicio'] ?? '';
            endControllers[day]!.text =
                horarioAtencion['${dayInSpanish}_hora_fin'] ?? '';
            isClosed[day] =
                (controller.text.isEmpty && endControllers[day]!.text.isEmpty);
          });
        });
      } else {
        print(
            'Failed to load room details. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load room details');
      }
    } catch (e) {
      print('Error loading room details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading room details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchServices() async {
    try {
      final clues = await _sharedPreferencesService.getClues();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar servicios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Intenta formatear la hora de [time] en formato "HH:mm:ss".
  /// Si no lo logra, lanza una excepción para que no continúe el registro.
  String _formatTime(String time) {
    try {
      time = time.replaceAll(RegExp(r'[\u202F\u00A0]'), '').trim();

      DateTime parsedTime;
      if (time.contains(RegExp(r'AM|PM', caseSensitive: false))) {
        parsedTime = DateFormat.jm().parse(time);
      } else {
        parsedTime = DateFormat.Hms().parse(time);
      }

      return DateFormat('HH:mm:ss').format(parsedTime);
    } catch (e) {
      print('Error formateando el tiempo: $e');
      throw FormatException('Invalid time format: $time');
    }
  }

  Future<void> updateRoomDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('$baseUrl/sala/sala/${widget.roomId}');
      Map<String, String?> horarioAtencionMap = {};

      // Manejo de horario de atención
      if (is24_7) {
        for (var day in startControllers.keys) {
          String dayInSpanish = dayTranslations[day]!;
          horarioAtencionMap['${dayInSpanish}_hora_inicio'] = "00:00:00";
          horarioAtencionMap['${dayInSpanish}_hora_fin'] = "23:59:59";
        }
      } else {
        for (var day in startControllers.keys) {
          String dayInSpanish = dayTranslations[day]!;

          if (isClosed[day]!) {
            horarioAtencionMap['${dayInSpanish}_hora_inicio'] = null;
            horarioAtencionMap['${dayInSpanish}_hora_fin'] = null;
          } else {
            final startTime = startControllers[day]!.text.isNotEmpty
                ? _formatTime(startControllers[day]!.text)
                : null;
            final endTime = endControllers[day]!.text.isNotEmpty
                ? _formatTime(endControllers[day]!.text)
                : null;

            horarioAtencionMap['${dayInSpanish}_hora_inicio'] = startTime;
            horarioAtencionMap['${dayInSpanish}_hora_fin'] = endTime;
          }
        }
      }

      // Armar el payload principal
      Map<String, dynamic> payload = {
        'nombre': nameController.text,
        'numero': int.tryParse(numberController.text) ?? 0,
        'id_servicio': int.tryParse(selectedServiceId ?? '') ?? 0,
        'maxBeds': int.tryParse(maxBedsController.text) ?? 0,
        'horarioAtencion': horarioAtencionMap,
        'hasVisitingHours': hasVisitingHours, // <-- Bandera importante
      };

      // Manejo de horario de visita según hasVisitingHours
      if (hasVisitingHours) {
        if (startVisitingController.text.isNotEmpty &&
            endVisitingController.text.isNotEmpty &&
            maxVisitsController.text.isNotEmpty) {
          final visitingStart = _formatTime(startVisitingController.text);
          final visitingEnd = _formatTime(endVisitingController.text);

          payload['horarioVisita'] = {
            'inicio': visitingStart,
            'fin': visitingEnd,
            'visitantes': int.tryParse(maxVisitsController.text) ?? 0,
          };
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please complete all visiting hours fields'),
            ),
          );
          return;
        }
      }
      // Si hasVisitingHours es false, no mandamos horarioVisita, el backend lo eliminará si existía

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print(
            'Failed to update room details. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update room details');
      }
    } on FormatException catch (fe) {
      print('Formato de hora inválido: ${fe.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid time format: ${fe.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Error updating room details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating room details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    if (!mounted) return;
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && mounted) {
      final now = DateTime.now();
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
    // Validar horarios si no es 24/7
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
        title: Text("Edit Room".tr()),
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
                      Text("Opening hours".tr()),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: 200,
                        child: CheckboxListTile(
                          title: Text("24/7".tr()),
                          value: is24_7,
                          onChanged: (value) {
                            setState(() {
                              is24_7 = value ?? false;
                              if (is24_7) {
                                startControllers.forEach(
                                    (_, controller) => controller.clear());
                                endControllers.forEach(
                                    (_, controller) => controller.clear());
                                isClosed.updateAll((key, _) => false);
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 5),
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
                                  SizedBox(width: 80, child: Text(day)),
                                  const SizedBox(width: 10),
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
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: TextFormField(
                                          controller: startController,
                                          readOnly: true,
                                          enabled: !isClosed[day]!,
                                          decoration: const InputDecoration(
                                            labelText: "Start time",
                                          ),
                                          onTap: () =>
                                              _selectTime(startController),
                                          validator: (value) {
                                            if (!isClosed[day]! &&
                                                (value == null ||
                                                    value.isEmpty)) {
                                              return 'Required'.tr();
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: 80,
                                        child: TextFormField(
                                          controller: endController,
                                          readOnly: true,
                                          enabled: !isClosed[day]!,
                                          decoration: const InputDecoration(
                                            labelText: "End time",
                                          ),
                                          onTap: () =>
                                              _selectTime(endController),
                                          validator: (value) {
                                            if (!isClosed[day]! &&
                                                (value == null ||
                                                    value.isEmpty)) {
                                              return 'Required'.tr();
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 30),
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
                                  width: 100,
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
                                  width: 100,
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
                              style: const TextStyle(fontSize: 13),
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
                            updateRoomDetails();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please enter valid times for all open days'),
                              ),
                            );
                          }
                        },
                        child: Text("Save Changes".tr()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
