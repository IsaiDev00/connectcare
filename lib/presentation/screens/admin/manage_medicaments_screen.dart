import 'dart:convert';

import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/presentation/screens/admin/update_medicament.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManageMedications extends StatefulWidget {
  const ManageMedications({super.key});

  @override
  State<ManageMedications> createState() => _ManageMedicationsState();
}

class _ManageMedicationsState extends State<ManageMedications> {
  List<Map<String, dynamic>> medicaments = [];
  List<Map<String, dynamic>> filterMedicaments = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    medicamentsInit();
  }

  Future<void> medicamentsInit() async {
    var url = Uri.parse('$baseUrl/medicamento');
    var response = await http.get(url);
    final List<dynamic> data = json.decode(response.body);
    setState(() {
      medicaments = data.map((item) {
        return {
          'id': item['id_medicamento'].toString(),
          'nombre': item['nombre'],
        };
      }).toList();
      filterMedicaments = List.from(medicaments);
    });
  }

  void updateFilter(String query) {
    setState(() {
      filterMedicaments = medicaments
          .where((medicament) =>
              medicament['nombre'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> deleteMedicament(String id) async {
    var url = Uri.parse('$baseUrl/medicamento/$id');
    var response = await http.delete(url);
    if (mounted) {
      responseHandlerDelete(response, context, 'Medicamento creado con exito',
          'Error al crear medicamento');
    }
    medicamentsInit();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Medicamentos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              SizedBox(
                width: 400,
                child: TextFormField(
                  controller: searchController,
                  onChanged: updateFilter,
                  decoration: const InputDecoration(
                    labelText: "Search...",
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
              ),
              const SizedBox(height: 20),
              filterMedicaments.isEmpty
                  ? SizedBox(
                      height: 450,
                      child: const Center(
                        child: Text(
                          'Nada que ver por aquí',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    )
                  :
                  //  Expanded(
                  SizedBox(
                      height: 450,
                      child: ListView.builder(
                        itemCount: filterMedicaments.length,
                        itemBuilder: (context, index) {
                          final item = filterMedicaments[index];
                          return ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['nombre'],
                                  style: theme.textTheme.headlineSmall,
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UpdateMedicamentScreen(
                                                    id: item['id']),
                                          ),
                                        );

                                        if (result == 'updated') {
                                          await medicamentsInit();
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () async {
                                        await deleteMedicament(item['id']);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                        context, '/createMedicamentScreen');
                    if (result == 'created') {
                      await medicamentsInit();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Agregar medicamento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
