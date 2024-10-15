import 'package:flutter/material.dart';
import 'package:connectcare/data/repositories/table/personal_repository.dart';
import 'package:connectcare/services/shared_preferences_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompleteStaffRegistration extends StatefulWidget {
  final User firebaseUser;

  const CompleteStaffRegistration({required this.firebaseUser, Key? key})
      : super(key: key);

  @override
  _CompleteStaffRegistrationState createState() =>
      _CompleteStaffRegistrationState();
}

class _CompleteStaffRegistrationState extends State<CompleteStaffRegistration> {
  final List<String> userTypes = [
    'Administrador',
    'Médico',
    'Enfermero',
    'Trabajador social',
    'Camillero',
    'Recursos humanos'
  ];

  final TextEditingController idController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNamePaternalController =
      TextEditingController();
  final TextEditingController lastNameMaternalController =
      TextEditingController();
  String? selectedUserType;

  final _formKey = GlobalKey<FormState>();
  final PersonalRepository _personalRepository = PersonalRepository();
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

                // Campo para el ID del personal
                TextFormField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'Staff ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your staff ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Campo para el nombre
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

                // Campo para el apellido paterno
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

                // Campo para el apellido materno
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

                // Campo para el tipo de usuario
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

                // Botón para completar el registro
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        // Insertar el nuevo usuario en la base de datos
                        await _personalRepository.insert({
                          'id_personal': idController.text,
                          'nombre': firstNameController.text,
                          'apellido_paterno': lastNamePaternalController.text,
                          'apellido_materno': lastNameMaternalController.text,
                          'tipo': selectedUserType,
                          'correo_electronico': widget.firebaseUser.email,
                          'firebase_uid': widget.firebaseUser.uid,
                          'telefono': null,
                          'contrasena': null,
                        });

                        // Guardar el ID del usuario de forma local
                        await _sharedPreferencesService
                            .saveUserId(idController.text);

                        // Mostrar mensaje de éxito y redirigir a la pantalla principal
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Registration successful'),
                          ),
                        );

                        Navigator.pushNamed(context, '/mainScreen');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Registration failed: $e'),
                          ),
                        );
                      }
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
}
