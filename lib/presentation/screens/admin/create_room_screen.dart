import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  _CreateRoomScreen createState() => _CreateRoomScreen();
}

class _CreateRoomScreen extends State<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  bool is24_7 = true;
  bool hasVisitingHours = false;

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

  Future<void> crearSalaConHorarios(
    String nombre,
    int numero,
    Map<String, TextEditingController> startControllers,
    Map<String, TextEditingController> endControllers,
    Map<String, bool> isClosed,
    TextEditingController maxVisitsController,
    TextEditingController startVisitingController,
    TextEditingController endVisitingController,
  ) async {
    final url = Uri.parse('$baseUrl/sala/crearSalaConHorarios');

    Map<String, Map<String, String?>> horarioAtencion = {};

    if (is24_7) {
      // Set all days to 00:00:00 to 00:00:00
      for (var day in startControllers.keys) {
        horarioAtencion[day] = {
          'hora_inicio': "00:00:00",
          'hora_fin': "00:00:00",
        };
      }
    } else {
      // Process manual opening hours
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
      'horarioAtencion': horarioAtencion,
      'maxBeds': int.parse(maxBedsController.text),
    };

    // Handle Visiting Hours if enabled
    if (hasVisitingHours) {
      // Validate visiting hours fields
      if (startVisitingController.text.isNotEmpty &&
          endVisitingController.text.isNotEmpty &&
          maxVisitsController.text.isNotEmpty) {
        payload['horarioVisita'] = {
          'inicio': _formatTime(startVisitingController.text),
          'fin': _formatTime(endVisitingController.text),
          'visitantes': int.parse(maxVisitsController.text),
        };
      } else {
        // Handle incomplete visiting hours data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please complete all visiting hours fields')),
        );
        return;
      }
    }

    // Convert data to JSON and send
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (response.statusCode == 201) {
      print('Registros creados exitosamente');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room created successfully!')),
      );
      Navigator.pop(context);
    } else {
      print('Error al crear los registros: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.body}')),
      );
    }
  }

  String _formatTime(String time) {
    // Convert "hh:mm AM/PM" to "HH:mm:ss"
    TimeOfDay tod = TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1].split(" ")[0]));
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return TimeOfDay.fromDateTime(dt).format(context).contains("PM")
        ? "${(tod.hour % 12) + 12}:${tod.minute.toString().padLeft(2, '0')}:00"
        : "${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}:00";
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
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      String formattedTime = pickedTime.format(context);
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
        title: const Text("Create Room"),
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
                      return 'Please enter a name for the room';
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
                      return 'Please enter a number for the room';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // OPENING HOURS
                Text("Opening hours"),
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
                          startControllers
                              .forEach((_, controller) => controller.clear());
                          endControllers
                              .forEach((_, controller) => controller.clear());
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
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                                title: const Text("Closed"),
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
                                    return 'Required';
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
                                    return 'Required';
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
                    title: Text("Add Visiting Hours"),
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
                      Text("Visiting hours"),
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
                              onTap: () => _selectTime(startVisitingController),
                              validator: (value) {
                                if (hasVisitingHours &&
                                    (value == null || value.isEmpty)) {
                                  return 'Required';
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
                              onTap: () => _selectTime(endVisitingController),
                              validator: (value) {
                                if (hasVisitingHours &&
                                    (value == null || value.isEmpty)) {
                                  return 'Required';
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
                              return 'Please enter a number of visitors';
                            }
                            int? num = int.tryParse(value);
                            if (num == null) {
                              return 'Invalid number';
                            }
                            if (num > 20) {
                              return 'Please enter a number below 20 visitors';
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
                      return 'Please enter a max number of beds/incubators/cribs';
                    }
                    int? num = int.tryParse(value);
                    if (num == null) {
                      return 'Invalid number';
                    }
                    if (num > 50) {
                      return 'Please enter a number below 50 beds/incubators/cribs';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _validateDays()) {
                      crearSalaConHorarios(
                        nameController.text,
                        int.parse(numberController.text),
                        startControllers,
                        endControllers,
                        isClosed,
                        maxVisitsController,
                        startVisitingController,
                        endVisitingController,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please enter valid times for all open days')),
                      );
                    }
                  },
                  child: const Text("Register Room"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
