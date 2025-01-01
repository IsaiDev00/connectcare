import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:connectcare/presentation/screens/admin/edit_procedure_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageProcedureScreen extends StatefulWidget {
  const ManageProcedureScreen({super.key});

  @override
  ManageProcedureScreenState createState() => ManageProcedureScreenState();
}

class ManageProcedureScreenState extends State<ManageProcedureScreen> {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  List<Map<String, dynamic>> procedures = [];
  List<Map<String, dynamic>> fliteredProcedures = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProcedures();
  }

  Future<void> _fetchProcedures() async {
    try {
      final clues = await _sharedPreferencesService.getClues();
      final response =
          await http.get(Uri.parse('$baseUrl/procedimiento/$clues'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          procedures = data
              .map((item) => {
                    'id_procedimiento': item['id_procedimiento'],
                    'nombre': item['nombre']
                  })
              .toList();
          fliteredProcedures = procedures;
        });
      } else {
        throw Exception('Error loading procedures');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void updateFilter(String query) {
    setState(() {
      fliteredProcedures = procedures.where((procedure) {
        final procedureName = procedure['nombre'].toLowerCase();
        return procedureName.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _confirmDeleteProcedure(int procedureID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete this procedure?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteProcedure(procedureID);
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteProcedure(int id) async {
    try {
      final response =
          await http.delete(Uri.parse('$baseUrl/procedimiento/$id'));
      print("id: $id");
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Procedure deleted successfully')),
        );
        _fetchProcedures();
      } else {
        throw Exception('Error deleting the procedure');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Procedures'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            // Barra de búsqueda
            TextFormField(
              controller: searchController,
              onChanged: updateFilter,
              decoration: const InputDecoration(
                labelText: "Search...",
                border: OutlineInputBorder(),
              ),
              autofocus: false,
            ),
            const SizedBox(height: 20),

            // Lista de procedimientos
            Expanded(
              child: fliteredProcedures.isEmpty
                  ? const Center(
                      child: Text(
                        'Nothing to see here',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: fliteredProcedures.length,
                      itemBuilder: (context, index) {
                        final procedure = fliteredProcedures[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              procedure['nombre'],
                              style: theme.textTheme.bodyLarge,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditProcedureScreen(
                                                procedureId: procedure[
                                                    'id_procedimiento']),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _confirmDeleteProcedure(
                                        procedure['id_procedimiento']);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),

            // Botón para agregar nuevo procedimiento
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/createProcedureScreen')
                      .then((value) {
                    if (value == 'refresh') {
                      _fetchProcedures();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Add Procedure'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
