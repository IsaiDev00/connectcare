import 'package:connectcare/data/services/user_service.dart';
import 'package:flutter/material.dart';

class PatientHistory extends StatefulWidget {
  const PatientHistory({super.key});

  @override
  PatientHistoryState createState() => PatientHistoryState();
}

class PatientHistoryState extends State<PatientHistory> {
  String? userId;
  String? userType;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await UserService().loadUserData();
    setState(() {
      userId = userData['userId'];
      userType = userData['userType'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HISTORIAL DEL PACIENTE'),
      ),
      body: Center(
        child: userId == null
            ? const CircularProgressIndicator()
            : Text(
                'HOLA',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
