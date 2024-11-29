import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SocialWorkerHomeScreen extends StatefulWidget {
  const SocialWorkerHomeScreen({super.key});

  @override
  SocialWorkerHomeScreenState createState() => SocialWorkerHomeScreenState();
}

class SocialWorkerHomeScreenState extends State<SocialWorkerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Worker Home'),
      ),
      body: Center(
        child: Text(
          'Welcome ${user?.displayName ?? "Social Worker"}, you are logged in as a Social Worker.',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
