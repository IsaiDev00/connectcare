import 'package:connectcare/main.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';

class CompleteStaffRegistration extends StatefulWidget {
  final User firebaseUser;

  const CompleteStaffRegistration({required this.firebaseUser, super.key});

  @override
  CompleteStaffRegistrationState createState() =>
      CompleteStaffRegistrationState();
}

class CompleteStaffRegistrationState extends State<CompleteStaffRegistration> {
  final List<String> userTypes = [
    'Administrator',
    'Doctor',
    'Nurse',
    'Social worker',
    'Stretcher bearer',
    'Human resources'
  ];

  final TextEditingController idController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNamePaternalController =
      TextEditingController();
  final TextEditingController lastNameMaternalController =
      TextEditingController();
  String? selectedUserType;

  final _formKey = GlobalKey<FormState>();
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Staff Registration'),
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
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'Staff ID',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your staff ID';
                    }
                    if (value.length != 8) {
                      return 'Staff ID must be exactly 8 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
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
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedUserType,
                  decoration: const InputDecoration(
                    labelText: 'User Type',
                    border: OutlineInputBorder(),
                  ),
                  items: userTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(
                        type,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedUserType = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a user type';
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
                  child: const Text('Register'),
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
        'id_personal': idController.text,
        'nombre': firstNameController.text,
        'apellido_paterno': lastNamePaternalController.text,
        'apellido_materno': lastNameMaternalController.text,
        'tipo': selectedUserType,
        'correo_electronico': firebaseUser.email ?? '',
        'firebase_uid': firebaseUser.uid,
        'auth_provider': firebaseUser.providerData[0].providerId,
        'estatus': 'activo',
      };

      final url = Uri.parse('$baseUrl/personal');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        await _sharedPreferencesService.saveUserId(firebaseUser.uid);

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
        final assignedHospital = userData['clues'] != null;

        if (!assignedHospital) {
          MyApp.nav.navigateTo('/mainScreenStaff');
          return;
        }

        switch (userType) {
          case 'medico':
          case 'doctor':
            MyApp.nav.navigateTo('/doctorHomeScreen');
            break;
          case 'enfermero':
          case 'nurse':
            MyApp.nav.navigateTo('/nurseHomeScreen');
            break;
          case 'camillero':
          case 'stretcher bearer':
            MyApp.nav.navigateTo('/stretcherBearerHomeScreen');
            break;
          case 'trabajo social':
          case 'social worker':
            MyApp.nav.navigateTo('/socialWorkerHomeScreen');
            break;
          case 'recursos humanos':
          case 'human resources':
            MyApp.nav.navigateTo('/humanResourcesHomeScreen');
            break;
          case 'administrador':
          case 'administrator':
            MyApp.nav.navigateTo('/mainScreen');
            break;
          default:
            throw Exception('Unknown user type');
        }
      } else {
        throw Exception('Error fetching user data: ${response.body}');
      }
    } catch (e) {
      _errorDeterminigUserType(e);
    }
  }

  void _errorDeterminigUserType(Object e) {
    showCustomSnackBar(context, 'Error determining user type: $e');
  }

  void _registrationFailed(Object e) {
    showCustomSnackBar(context, 'Registration failed: $e');
  }
}
