import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  _CreateRoomScreen createState() => _CreateRoomScreen();
}

class _CreateRoomScreen extends State<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  bool is24_7 = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
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

  // Para indicar si la sala está cerrada un día específico
  final Map<String, bool> isClosed = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  @override
  void dispose() {
    startControllers.forEach((_, controller) => controller.dispose());
    endControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      controller.text = pickedTime.format(context);
    }
  }

  bool _validateDays() {
    // Verifica si cada día tiene horario o está marcado como cerrado
    for (var day in startControllers.keys) {
      if (!isClosed[day]! &&
          (startControllers[day]!.text.isEmpty ||
              endControllers[day]!.text.isEmpty)) {
        return false;
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

                // NOMBRE DE LA SALA
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

                // NUMERO DE SALA
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

                const SizedBox(height: 15),

                // HORARIOS DE ATENCION
                Text("Opening hours"),
                const SizedBox(height: 10),
                Text(
                    "(If isn't 24/7 please uncheck the box and enter the opening hours per each day.)"),
                SizedBox(
                  width: 200,
                  child: CheckboxListTile(
                    title: Text("24/7"),
                    value: is24_7,
                    onChanged: (value) {
                      setState(() {
                        is24_7 = value ?? false;
                      });
                    },
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
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 15),

                // CANTIDAD MAXIMA DE VISITAS
                TextFormField(
                  controller: maxVisitsController,
                  decoration: const InputDecoration(
                    labelText: "Max number of visitors",
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number of visitors';
                    }
                    if (int.tryParse(value)! > 20) {
                      return 'Please enter a number below 20 visitors';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // CANTIDAD MAXIMA DE CAMAS
                TextFormField(
                  controller: maxBedsController,
                  decoration: const InputDecoration(
                    labelText: "Max number of beds/incubators/cribs",
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a max number of beds/incubators/cribs';
                    }
                    if (int.tryParse(value)! > 50) {
                      return 'Please enter a number below 50 beds/incubators/cribs';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Botón para validar el formulario
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _validateDays()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('All validations passed!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please enter valid times for all open days')),
                      );
                    }
                  },
                  child: const Text("Validate"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
