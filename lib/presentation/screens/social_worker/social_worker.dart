import 'package:connectcare/data/services/user_service.dart';
import 'package:flutter/material.dart';

class SocialWorkerHomeScreen extends StatefulWidget {
  const SocialWorkerHomeScreen({super.key});

  @override
  SocialWorkerHomeScreenState createState() => SocialWorkerHomeScreenState();
}

class SocialWorkerHomeScreenState extends State<SocialWorkerHomeScreen> {
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
        title: const Text('Social Worker Home'),
      ),
      body: Center(
        child: userId == null
            ? const CircularProgressIndicator()
            : Text(
                'Welcome $userId, you are logged in as a $userType.',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
