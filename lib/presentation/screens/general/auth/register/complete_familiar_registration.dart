import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/presentation/screens/general/dynamic_wrapper.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';

class CompleteFamiliarRegistration extends StatefulWidget {
  final User firebaseUser;

  const CompleteFamiliarRegistration({required this.firebaseUser, super.key});

  @override
  CompleteFamiliarRegistrationState createState() =>
      CompleteFamiliarRegistrationState();
}

class CompleteFamiliarRegistrationState
    extends State<CompleteFamiliarRegistration> {
  final userService = UserService();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNamePaternalController =
      TextEditingController();
  final TextEditingController lastNameMaternalController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Familiar Registration'.tr()),
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
                  decoration: InputDecoration(
                    labelText: 'First Name'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: lastNamePaternalController,
                  decoration: InputDecoration(
                    labelText: 'Last Name (Paternal)'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your paternal last name'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: lastNameMaternalController,
                  decoration: InputDecoration(
                    labelText: 'Last Name (Maternal)'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your maternal last name'.tr();
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
                  child: Text('Register'.tr()),
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
        'nombre': firstNameController.text.trim(),
        'apellido_paterno': lastNamePaternalController.text.trim(),
        'apellido_materno': lastNameMaternalController.text.trim(),
        'tipo': "regular",
        'correo_electronico': firebaseUser.email!.trim().toLowerCase(),
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
        final responseData = jsonDecode(response.body);

        final userId = responseData['id_familiar'].toString();
        final userType = responseData['tipo'];

        await userService.saveUserSession(userId, userType);

        if (mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DynamicWrapper()),
              (route) => false);
        }
      } else {
        throw Exception('Registration failed'.tr());
      }
    } catch (e) {
      _registrationFailed();
    }
  }

  void _registrationFailed() {
    showCustomSnackBar(context, 'Registration failed'.tr());
  }
}
