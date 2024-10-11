import 'package:flutter/material.dart';

class ManageProcedureScreen extends StatefulWidget {
  const ManageProcedureScreen({super.key});

  @override
  _ManageProcedureScreenState createState() => _ManageProcedureScreenState();
}

class _ManageProcedureScreenState extends State<ManageProcedureScreen> {
  List<String> procedures = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Procedimientos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: procedures.isEmpty
                  ? const Center(
                      child: Text(
                        'Nada que ver por aquí',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: procedures.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(procedures[index]),
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: () {
                // Lógica para agregar un nuevo procedimiento
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Agregar procedimiento'),
            ),
          ],
        ),
      ),
    );
  }
}
