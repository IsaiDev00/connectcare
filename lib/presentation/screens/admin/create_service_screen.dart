import 'package:connectcare/core/constants/constants.dart';
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

  List<Map<String, dynamic>> areas = [];

  final TextEditingController nameController = TextEditingController();
  String? areaController;

  @override
  void initState() {
    super.initState();
    _fetchItemsFromDatabase(); // Llama a la función para obtener los datos al iniciar
  }

  Future<void> _fetchItemsFromDatabase() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/items')); // URL de tu API

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          areas = data.map((item) => {'name': item['name'], 'isChecked': false}).toList();
        });
      } else {
        throw Exception('Error al cargar los datos');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  bool isAnyItemChecked() {
    return areas.any((item) => item['isChecked'] == true);
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

                //NOMBRE
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
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                //AREA
                ExpansionTile(
                  title: const Text("Select Area"),
                  children: areas.map((item) {
                    return CheckboxListTile(
                      title: Text(item['name']),
                      value: item['isChecked'],
                      onChanged: (bool? value) {
                        setState(() {
                          item['isChecked'] = value!;
                        });
                      },
                    );
                  }).toList(),
                ),

                SizedBox(height: 15),

                //GUARDAR
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        isAnyItemChecked()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bien hecho')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please enter at least one Area')));
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
