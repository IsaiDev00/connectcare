import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainFamilyMemberHomeScreen extends StatefulWidget {
  const MainFamilyMemberHomeScreen({super.key});

  @override
  MainFamilyMemberHomeScreenState createState() =>
      MainFamilyMemberHomeScreenState();
}

class MainFamilyMemberHomeScreenState
    extends State<MainFamilyMemberHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Family Member Home'),
      ),
      body: Center(
        child: Text(
          'Welcome ${user?.displayName ?? "Family Member"}, you are logged in as the Main Family Member.',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
