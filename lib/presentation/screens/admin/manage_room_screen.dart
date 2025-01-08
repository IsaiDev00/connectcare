import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:connectcare/presentation/screens/admin/SAMM/wifi_credentials_screen.dart';
import 'package:connectcare/presentation/screens/admin/edit_room_screen.dart';
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

  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    try {
      final clues = await _sharedPreferencesService.getClues();
      final response = await http.get(Uri.parse('$baseUrl/sala/$clues'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          rooms = data
              .map((item) => {
                    'id_sala': item['id_sala'],
                    'nombre':
                        '${item['nombre_sala']} ${item['numero_sala']} - ${item['nombre_servicio']}'
                  })
              .toList();
          filteredRooms = rooms; // Inicializa con todas las salas
        });
      } else {
        throw Exception('Error loading rooms');
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

  void _confirmDeleteRoom(int roomID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this room?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteRoom(roomID);
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteRoom(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/sala/$id'));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room deleted successfully')),
        );
        _fetchRooms();
      } else {
        print('Error: ${response.body}'); // Mostrar el cuerpo de la respuesta
        throw Exception('Error deleting the room');
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
        title: const Text('Manage Rooms'),
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

            Text(
                "To program the SAMM devices of a room, just click on the room"),
            const SizedBox(height: 20),

            // Lista de salas
            Expanded(
              child: filteredRooms.isEmpty
                  ? const Center(
                      child: Text(
                        'Nothing to see here',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredRooms.length,
                      itemBuilder: (context, index) {
                        final room = filteredRooms[index];
                        return InkWell(
                          onTap: () {
                            // Navegar a la pantalla deseada
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WifiCredentialsScreen(roomID: room['id_sala'].toString()),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                room['nombre'],
                                style: theme.textTheme.bodyLarge,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      // Navegar a la pantalla de edición de la sala con roomId
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditRoomScreen(
                                              roomId: room['id_sala']),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _confirmDeleteRoom(room['id_sala']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),

            // Botón para agregar nueva sala
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/createRoomScreen')
                      .then((value) {
                    if (value == 'refresh') {
                      _fetchRooms();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Add Room'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
