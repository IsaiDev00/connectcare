import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageRoomScreen extends StatefulWidget {
  const ManageRoomScreen({super.key});

  @override
  ManageRoomScreenState createState() => ManageRoomScreenState();
}

class ManageRoomScreenState extends State<ManageRoomScreen> {
  List<Map<String, dynamic>> rooms = [];
  List<Map<String, dynamic>> filteredRooms = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sala/salas'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          rooms = data
              .map((item) => {
                    'id_sala': item['id_sala'],
                    'nombre':
                        '${item['nombre_sala']} ${item['numero']} - ${item['nombre_servicio']}'
                  })
              .toList();
          filteredRooms = rooms; // Inicializa con todas las salas
        });
      } else {
        throw Exception('Error al cargar las salas');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void updateFilter(String query) {
    setState(() {
      filteredRooms = rooms.where((room) {
        final roomName = room['nombre'].toLowerCase();
        return roomName.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Salas'),
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
              filteredRooms.isEmpty
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
                        itemCount: filteredRooms.length,
                        itemBuilder: (context, index) {
                          final room = filteredRooms[index];
                          return ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  room['nombre'],
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
                  Navigator.pushNamed(context, '/createRoomScreen');
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
