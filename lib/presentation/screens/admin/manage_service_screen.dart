import 'package:flutter/material.dart';

class ManageServiceScreen extends StatefulWidget {
  const ManageServiceScreen({super.key});

  @override
  _ManageServiceScreenState createState() => _ManageServiceScreenState();
}

class _ManageServiceScreenState extends State<ManageServiceScreen> {
  List<String> services = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Servicios'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: services.isEmpty
                  ? const Center(
                      child: Text(
                        'Nada que ver por aquí',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(services[index]),
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/createServiceScreen');
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Agregar servicio'),
            ),
          ],
        ),
      ),
    );
  }
}
