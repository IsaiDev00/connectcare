import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HumanResourcesHomeScreen extends StatefulWidget {
  const HumanResourcesHomeScreen({super.key});

  @override
  HumanResourcesHomeScreenState createState() =>
      HumanResourcesHomeScreenState();
}

class HumanResourcesHomeScreenState extends State<HumanResourcesHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Human Resources Home'),
      ),
      body: Center(
        child: Text(
          'Welcome ${user?.displayName ?? "Human Resources"}, you are logged in as a Human Resources member.',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
