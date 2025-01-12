import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/presentation/screens/general/dynamic_wrapper.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';

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
  final userService = UserService();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Staff Registration'.tr()),
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
                  decoration: InputDecoration(
                    labelText: 'Staff ID'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your staff ID'.tr();
                    }
                    if (value.length != 8) {
                      return 'Staff ID must be exactly 8 digits'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
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
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedUserType,
                  decoration: InputDecoration(
                    labelText: 'User Type'.tr(),
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
                      return 'Please select a user type'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bool staffIdExists =
                          await checkStaffIdExists(idController.text);
                      if (staffIdExists) {
                        _staffIdInUse();
                        return;
                      }
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
        'id_personal': idController.text,
        'nombre': firstNameController.text.trim(),
        'apellido_paterno': lastNamePaternalController.text.trim(),
        'apellido_materno': lastNameMaternalController.text.trim(),
        'tipo': selectedUserType!.toLowerCase(),
        'correo_electronico': firebaseUser.email!.trim().toLowerCase(),
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
        final responseData = jsonDecode(response.body);

        final userId = responseData['id_personal'].toString();
        final userType = responseData['tipo'];

        await userService.saveUserSession(userId, userType: userType);

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
      _registrationFailed(e);
    }
  }

  void _registrationFailed(Object e) {
    showCustomSnackBar(context, 'Registration failed'.tr());
  }

  Future<bool> checkStaffIdExists(String staffId) async {
    final url = Uri.parse('$baseUrl/personal/id/$staffId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      return false;
    } else {
      throw Exception('Error verifying Staff ID'.tr());
    }
  }

  void _staffIdInUse() {
    showCustomSnackBar(context, 'Staff ID is already in use'.tr());
  }
}
