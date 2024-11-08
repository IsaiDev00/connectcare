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
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    final clues = await _sharedPreferencesService.getClues();
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/servicio/servicios/$clues')); // URL de tu API

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          services = data
              .map((item) => {
                    'nombre': item['servicio_nombre'],
                    'piso': item['numero_piso'],
                    'id': item['id_servicio']
                  })
              .toList();
          filteredServices =
              services; // Inicializar filtro con todos los servicios
        });
      } else {
        throw Exception('Error loading services');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteService(int id) async {
    try{
      final response = await http.delete(Uri.parse('$baseUrl/servicio/$id'));

      if(response.statusCode == 200){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted successfully')),
        );
        _fetchServices();
      } else {
        throw Exception('Error deleting the service');
      }
    } catch (e){
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

  void _confirmDeleteService(int serviceID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this service?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteService(serviceID);
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
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

            // Lista de servicios
            Expanded(
              child: filteredServices.isEmpty
                  ? const Center(
                      child: Text(
                        'Nothing to see here',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredServices.length,
                      itemBuilder: (context, index) {
                        final service = filteredServices[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              '${service['nombre']} - Floor ${service['piso']}',
                              style: theme.textTheme.bodyLarge,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // Acción para editar el servicio
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _confirmDeleteService(service['id']);
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

            // Botón para agregar nuevo servicio
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/createServiceScreen');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Add Service'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
