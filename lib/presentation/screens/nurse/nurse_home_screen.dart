import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NurseHomeScreen extends StatefulWidget {
  const NurseHomeScreen({super.key});

  @override
  NurseHomeScreenState createState() => NurseHomeScreenState();
}

class NurseHomeScreenState extends State<NurseHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nurse Home'),
      ),
      body: Center(
        child: Text(
          'Welcome ${user?.displayName ?? "Nurse"}, you are logged in as a Nurse.',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
