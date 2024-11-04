import 'package:flutter/material.dart';

class Management extends StatefulWidget {
  const Management({super.key});

  @override
  ManagementState createState() => ManagementState();
}

class ManagementState extends State<Management> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.7,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/manageServiceScreen');
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Servicios'),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.7,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/manageRoomScreen');
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Salas'),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.7,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/manageProcedureScreen');
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Procedimientos'),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.7,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/manageMedications');
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Medicamentos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
