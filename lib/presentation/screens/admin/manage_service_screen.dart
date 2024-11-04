import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageServiceScreen extends StatefulWidget {
  const ManageServiceScreen({super.key});

  @override
  ManageServiceScreenState createState() => ManageServiceScreenState();
}

class ManageServiceScreenState extends State<ManageServiceScreen> {
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> filteredServices = [];
  TextEditingController searchController = TextEditingController();
  final SharedPreferencesService _sharedPreferencesService = SharedPreferencesService();

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    final clues = await _sharedPreferencesService.getClues();
    try {
      final response = await http.get(Uri.parse('$baseUrl/servicio/servicios/$clues')); // URL de tu API

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          services = data
              .map((item) => {
                    'nombre': item['servicio_nombre'],
                    'piso': item['numero_piso']
                  })
              .toList();
          filteredServices = services; // Inicializar filtro con todos los servicios
        });
      } else {
        throw Exception('Error al cargar los servicios');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void updateFilter(String query) {
    setState(() {
      filteredServices = services.where((service) {
        final serviceName = service['nombre'].toLowerCase();
        final floorNumber = 'Floor ${service['piso']}';

        // Verificar si el nombre del servicio o el piso coinciden con la búsqueda
        return serviceName.contains(query.toLowerCase()) ||
               floorNumber.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Servicios'),
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

              // Lista de servicios
              filteredServices.isEmpty
                  ? const Center(
                      child: Text(
                        'Nada que ver por aquí',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : SizedBox(
                      height: 450,
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: ListView.builder(
                        itemCount: filteredServices.length,
                        itemBuilder: (context, index) {
                          final service = filteredServices[index];
                          return ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${service['nombre']} - Floor ${service['piso']}',
                                  style: theme.textTheme.headlineLarge,
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        // Acción para editar el servicio
                                      },
                                    ),
                                    SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        // Acción para eliminar el servicio
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

              // Botón para agregar nuevo servicio
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/createServiceScreen');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Agregar servicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
