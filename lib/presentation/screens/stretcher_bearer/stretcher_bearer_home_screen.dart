import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StretcherBearerHomeScreen extends StatefulWidget {
  const StretcherBearerHomeScreen({super.key});

  @override
  StretcherBearerHomeScreenState createState() =>
      StretcherBearerHomeScreenState();
}

class StretcherBearerHomeScreenState extends State<StretcherBearerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stretcher Bearer Home'),
      ),
      body: Center(
        child: Text(
          'Welcome ${user?.displayName ?? "Stretcher Bearer"}, you are logged in as a Stretcher Bearer.',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
