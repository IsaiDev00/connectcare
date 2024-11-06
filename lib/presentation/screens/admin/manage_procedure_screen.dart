import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageProcedureScreen extends StatefulWidget {
  const ManageProcedureScreen({super.key});

  @override
  ManageProcedureScreenState createState() => ManageProcedureScreenState();
}

class ManageProcedureScreenState extends State<ManageProcedureScreen> {
  List<Map<String, dynamic>> procedures = [];
  List <Map<String, dynamic>> fliteredProcedures = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState(){
    super.initState();
    _fetchProcedures();
  }

  Future<void> _fetchProcedures() async{
    try {
      final response = await http.get(Uri.parse('$baseUrl/procedimiento/'));

      if(response.statusCode == 200){
        List<dynamic> data = json.decode(response.body);

        setState(() {
          procedures = data.map((item) => {
            'id_procedimiento': item['id_procedimiento'],
            'nombre': item['nombre']
          }).toList();
          fliteredProcedures = procedures;
        });
      } else {
        throw Exception('Error al cargar los procedimientos');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void updateFilter(String query){
    setState(() {
      fliteredProcedures = procedures.where((procedure) {
        final procedureName = procedure['nombre'].toLowerCase();
        return procedureName.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Procedimientos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
          
              // Barra de búsqueda
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
                ),
              ),
              const SizedBox(height: 20),
          
              // Lista de salas
              fliteredProcedures.isEmpty
                  ? const Center(
                      child: Text(
                        'Nada que ver por aquí',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : SizedBox(
                      height: 450, // Altura fija para la lista
                      width: MediaQuery.of(context).size.width /
                          1.5, // Ancho responsivo similar a ManageServiceScreen
                      child: ListView.builder(
                        itemCount: fliteredProcedures.length,
                        itemBuilder: (context, index) {
                          final procedure = fliteredProcedures[index];
                          return ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  procedure['nombre'],
                                  style: theme.textTheme.headlineLarge,
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        // Acción para editar la sala
                                      },
                                    ),
                                    SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        // Acción para eliminar la sala
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
          
              // Botón para agregar nueva sala
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/createProcedureScreen');
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Agregar sala'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
