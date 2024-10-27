import 'package:flutter/material.dart';

class ManageRoomScreen extends StatefulWidget {
  const ManageRoomScreen({super.key});

  @override
  _ManageRoomScreenState createState() => _ManageRoomScreenState();
}

class _ManageRoomScreenState extends State<ManageRoomScreen> {
  List<String> rooms = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Salas'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: rooms.isEmpty
                  ? const Center(
                      child: Text(
                        'Nada que ver por aquí',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(rooms[index]),
                        );
                      },
                    ),
            ),
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
    );
  }
}
