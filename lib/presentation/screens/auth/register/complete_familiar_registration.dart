import 'package:connectcare/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';

class CompleteFamiliarRegistration extends StatefulWidget {
  final User firebaseUser;

  const CompleteFamiliarRegistration({required this.firebaseUser, super.key});

  @override
  CompleteFamiliarRegistrationState createState() =>
      CompleteFamiliarRegistrationState();
}

class CompleteFamiliarRegistrationState
    extends State<CompleteFamiliarRegistration> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNamePaternalController =
      TextEditingController();
  final TextEditingController lastNameMaternalController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Familiar Registration'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: lastNamePaternalController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name (Paternal)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your paternal last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: lastNameMaternalController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name (Maternal)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your maternal last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _registerUser();
                    }
                  },
                  child: const Text('Complete Registration'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    try {
      final firebaseUser = widget.firebaseUser;

      final requestBody = {
        'nombre': firstNameController.text,
        'apellido_paterno': lastNamePaternalController.text,
        'apellido_materno': lastNameMaternalController.text,
        'correo_electronico': firebaseUser.email ?? '',
        'firebase_uid': firebaseUser.uid,
        'auth_provider': firebaseUser.providerData[0].providerId,
      };

      final url = Uri.parse('$baseUrl/familiar');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        await _sharedPreferencesService.saveUserId(firebaseUser.uid);
        _registrationSuccesful();

        await _navigateToCorrectScreen(firebaseUser.uid);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      _registrationFailed(e);
    }
  }

  Future<void> _navigateToCorrectScreen(String firebaseUid) async {
    try {
      final url = Uri.parse('$baseUrl/auth/firebase_uid/$firebaseUid');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final userType = userData['tipo'].toLowerCase();

        switch (userType) {
          case 'familiar principal':
          case 'main family member':
            MyApp.nav.navigateTo('/mainFamiliMemberHomeScreen');
            break;
          case 'familiar regular':
          case 'regular family member':
            MyApp.nav.navigateTo('/regularFamilyMemberHomeScreen');
            break;
          default:
            throw Exception('Unknown user type');
        }
      } else {
        throw Exception('Error fetching user data: ${response.body}');
      }
    } catch (e) {
      _errorDeterminigUsertype(e);
    }
  }

  void _registrationSuccesful() {
    showCustomSnackBar(context, "Registration successful");
  }

  void _registrationFailed(Object e) {
    showCustomSnackBar(context, 'Registration failed: $e');
  }

  void _errorDeterminigUsertype(Object e) {
    showCustomSnackBar(context, 'Error determining user type: $e');
  }
}
