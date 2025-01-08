import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/presentation/screens/patient/nfc_bracelet_screen.dart';
import 'package:flutter/material.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  DoctorHomeScreenState createState() => DoctorHomeScreenState();
}

class DoctorHomeScreenState extends State<DoctorHomeScreen> {
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
        title: const Text('Doctor Home'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            userId == null
                ? const CircularProgressIndicator()
                : Text(
                    'Welcome $userId\nYou are logged in as a $userType.',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NfcBraceletScreen(user: userId.toString()),
                    ),
                  );
                },
                child: Text("Program NFC bracelet"))
          ],
        ),
      ),
    );
  }
}
