import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegularFamilyMemberHomeScreen extends StatefulWidget {
  const RegularFamilyMemberHomeScreen({super.key});

  @override
  RegularFamilyMemberHomeScreenState createState() =>
      RegularFamilyMemberHomeScreenState();
}

class RegularFamilyMemberHomeScreenState
    extends State<RegularFamilyMemberHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regular Family Member Home'),
      ),
      body: Center(
        child: Text(
          'Welcome ${user?.displayName ?? "Family Member"}, you are logged in as a Regular Family Member.',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
