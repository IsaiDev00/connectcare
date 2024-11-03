import 'package:flutter/material.dart';
import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:connectcare/services/shared_preferences_service.dart';
import 'package:connectcare/data/api/google_auth.dart';
import 'package:connectcare/data/api/facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectcare/presentation/screens/auth/complete_staff_registration.dart';

class HospitalStaffRegistration extends StatefulWidget {
  const HospitalStaffRegistration({super.key});

  @override
  HospitalStaffRegistrationState createState() =>
      HospitalStaffRegistrationState();
}

class HospitalStaffRegistrationState extends State<HospitalStaffRegistration> {
  final List<String> userTypes = [
    'Administrador',
    'Médico',
    'Enfermero',
    'Trabajador social',
    'Camillero',
    'Recursos humanos'
  ];

  final _formKey = GlobalKey<FormState>();

  bool isEmailMode = false;

  String? _selectedUserType;
  final TextEditingController idController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNamePaternalController =
      TextEditingController();
  final TextEditingController _lastNameMaternalController =
      TextEditingController();
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final FacebookAuthService _facebookAuthService = FacebookAuthService();

  Future<bool> checkEmailExists(String email) async {
    var url = Uri.parse('$baseUrl/personal/email/$email');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> checkPhoneExists(String phone) async {
    var url = Uri.parse('$baseUrl/personal/telefono/$phone');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register with ConnectCare'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:
              brightness == Brightness.dark ? Colors.transparent : Colors.white,
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: brightness == Brightness.dark
              ? Brightness.dark
              : Brightness.light,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Añadimos el GlobalKey al Form
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),

                // Campo para el ID
                TextFormField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'Staff ID',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
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

                // Campo para el nombre
                TextFormField(
                  controller: _firstNameController,
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
                  controller: _lastNamePaternalController,
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
                  controller: _lastNameMaternalController,
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
                  value: _selectedUserType,
                  decoration: const InputDecoration(
                    labelText: 'User type',
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
                      _selectedUserType = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a user type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Campo dinámico para el número de teléfono o correo electrónico
                TextFormField(
                  controller: _emailOrPhoneController,
                  decoration: InputDecoration(
                    labelText: isEmailMode ? 'Email Address' : 'Phone Number',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: isEmailMode
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  inputFormatters: isEmailMode
                      ? [] // Permitir cualquier entrada para el correo electrónico
                      : [
                          FilteringTextInputFormatter.digitsOnly
                        ], // Solo números para el teléfono
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEmailMode
                          ? 'Please enter your email address'
                          : 'Please enter your phone number';
                    }
                    if (isEmailMode) {
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                    } else {
                      final phoneRegex = RegExp(r'^\d{10}$');
                      if (!phoneRegex.hasMatch(value)) {
                        return 'Please enter a valid 10-digit phone number';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // Campo para la contraseña
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    final passwordRegex = RegExp(
                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$%^&*()!]).{8,}$');

                    if (!passwordRegex.hasMatch(value)) {
                      return 'Password must be at least 8 characters and include uppercase, lowercase, numbers, and symbols';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Campo para confirmar la contraseña
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Botón para continuar
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      // Verificar si el email o teléfono ya existe
                      bool emailExists = isEmailMode
                          ? await checkEmailExists(_emailOrPhoneController.text)
                          : false;
                      bool phoneExists = !isEmailMode
                          ? await checkPhoneExists(_emailOrPhoneController.text)
                          : false;

                      if (emailExists) {
                        scaffoldMessenger.showSnackBar(SnackBar(
                            content: Text('El correo ya está registrado')));
                        return;
                      } else if (phoneExists) {
                        scaffoldMessenger.showSnackBar(SnackBar(
                            content: Text('El teléfono ya está registrado')));
                        return;
                      }

                      try {
                        Map<String, dynamic> requestBody = {
                          'id_personal': idController.text,
                          'nombre': _firstNameController.text,
                          'apellido_paterno': _lastNamePaternalController.text,
                          'apellido_materno': _lastNameMaternalController.text,
                          'tipo': _selectedUserType,
                          'correo_electronico':
                              isEmailMode ? _emailOrPhoneController.text : null,
                          'telefono':
                              isEmailMode ? null : _emailOrPhoneController.text,
                          'contrasena': _passwordController.text,
                          'estatus': 'activo',
                          'auth_provider': isEmailMode
                              ? 'email'
                              : 'phone' // Agregar este campo
                        };

                        // peticion al api rest
                        var url = Uri.parse('$baseUrl/personal');
                        var response = await http.post(
                          url,
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(requestBody),
                        );

                        // validaciones
                        try {
                          var responseBody = jsonDecode(response.body);
                          if (response.statusCode == 201) {
                            String idPersonal =
                                responseBody['id_personal'].toString();
                            await _sharedPreferencesService
                                .saveUserId(idPersonal);
                            scaffoldMessenger.showSnackBar(SnackBar(
                                content: Text('Registration successful')));
                            _navigateToMainScreen();
                          } else {
                            scaffoldMessenger.showSnackBar(SnackBar(
                                content: Text(responseBody['error'] ??
                                    'Registration failed')));
                          }
                        } catch (e) {
                          //por si no es json
                          scaffoldMessenger.showSnackBar(SnackBar(
                              content: Text('Error: ${response.body}')));
                        }
                      } catch (e) {
                        scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text('Registration failed: $e')));
                      }
                    }
                  },
                  child: const Text('Continue'),
                ),

                const SizedBox(height: 20),

                // Texto "or"
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("or"),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),

                // Botón para alternar entre Email y Teléfono
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isEmailMode = !isEmailMode;
                      _emailOrPhoneController.clear();
                    });
                  },
                  icon: Icon(
                    isEmailMode ? Icons.phone : Icons.email_outlined,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  label: Text(
                    isEmailMode ? 'Continue with Phone' : 'Continue with Email',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 10),

                // Botón para iniciar sesión con Facebook
                ElevatedButton.icon(
                  onPressed: () async {
                    await _registerWithFacebook();
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.facebook,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.blue,
                  ),
                  label: Text(
                    'Continue with Facebook',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 10),

                // Botón para iniciar sesión con Google
                ElevatedButton.icon(
                  onPressed: () async {
                    await _registerWithGoogle();
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.google,
                    color: brightness == Brightness.dark
                        ? Colors.white
                        : Colors.red,
                  ),
                  label: Text(
                    'Continue with Google',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    elevation: 0,
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToMainScreen() {
    Navigator.pushNamed(context, '/mainScreen');
  }

  void _showSnackBarMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _registerWithGoogle() async {
    try {
      final userCredential = await _googleAuthService.signInWithGoogle();
      if (userCredential != null) {
        final firebaseUser = userCredential.user;
        if (firebaseUser != null) {
          // Navega a CompleteStaffRegistration sin intentar insertar en la base de datos
          _navigateToCompleteStaffRegistration(firebaseUser);
        }
      }
    } catch (e) {
      _showSnackBarMessage(e.toString());
    }
  }

  Future<void> _registerWithFacebook() async {
    final String? errorMessage;
    try {
      errorMessage = await _facebookAuthService.signInWithFacebook();
    } catch (e) {
      _showSnackBarMessage('Error inesperado: $e');
      return;
    }

    if (errorMessage == null) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        // Navega a CompleteStaffRegistration sin intentar insertar en la base de datos
        _navigateToCompleteStaffRegistration(firebaseUser);
      }
    } else {
      _showSnackBarMessage(errorMessage);
    }
  }

  void _navigateToCompleteStaffRegistration(User firebaseUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CompleteStaffRegistration(firebaseUser: firebaseUser),
      ),
    );
  }
}
