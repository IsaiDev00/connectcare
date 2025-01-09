import 'package:connectcare/data/services/user_service.dart';
import 'package:flutter/material.dart';

class ProgressNote extends StatefulWidget {
  const ProgressNote({super.key});

  @override
  ProgressNoteState createState() => ProgressNoteState();
}

class ProgressNoteState extends State<ProgressNote> {
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
        title: const Text('NOTA DE EVOLUCIÓN'),
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
