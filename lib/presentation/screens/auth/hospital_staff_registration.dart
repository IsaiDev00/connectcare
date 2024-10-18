import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; // Importa el paquete http
import 'dart:convert'; // Para convertir JSON
import 'package:connectcare/data/repositories/table/personal_repository.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:connectcare/services/shared_preferences_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  bool isEmailMode =
      false; // Variable para controlar si estamos en modo email o phone

  // Controladores de texto para cada campo
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

  // Define el URL base de tu backend
  final String _baseUrl =
      'http://127.0.0.1:8080'; // Cambia esto por el URL de tu backend

  // Reinstanciamos SharedPreferencesService
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

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
                    labelText: 'Tipo de Usuario',
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
                      return 'Por favor selecciona un tipo de usuario';
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

                      try {
                        // Construye el cuerpo de la solicitud
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
                          'estatus': 'activo' // Ajusta según tus necesidades
                        };

                        // Realiza la solicitud POST al backend
                        var url = Uri.parse('$_baseUrl/staff/signup');
                        var response = await http.post(
                          url,
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(requestBody),
                        );

                        // Mostrar la respuesta del servidor en el SnackBar para depurar
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Server response: ${response.body}'),
                          ),
                        );

                        if (response.statusCode == 201) {
                          // Registro exitoso
                          var responseBody = jsonDecode(response.body);
                          String idPersonal =
                              responseBody['id_personal'].toString();

                          // Guardar el ID del usuario de forma local
                          await _sharedPreferencesService
                              .saveUserId(idPersonal);

                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Registration successful'),
                            ),
                          );
                          Navigator.pushNamed(context, '/mainScreen');
                        } else {
                          // Error en el registro, intentar decodificar el JSON o mostrar el mensaje directamente
                          try {
                            var responseBody = jsonDecode(response.body);
                            String errorMessage =
                                responseBody['error'] ?? 'Registration failed';
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                              ),
                            );
                          } catch (e) {
                            // Si no se puede decodificar el JSON, mostrar el contenido tal cual
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text('Error: ${response.body}'),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        // Error durante el proceso de registro (red, JSON, etc.)
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Registration failed: $e'),
                          ),
                        );
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

                // Botón para iniciar sesión con Facebook (Lógica pendiente)
                ElevatedButton.icon(
                  onPressed: () {
                    // Lógica para iniciar sesión con Facebook
                  },
                  icon: FaIcon(FontAwesomeIcons.facebook,
                      color: brightness == Brightness.dark
                          ? Colors.white
                          : Colors.blue),
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
                  onPressed: _signInWithGoogle,
                  icon: FaIcon(FontAwesomeIcons.google,
                      color: brightness == Brightness.dark
                          ? Colors.white
                          : Colors.red),
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

                // Botón para iniciar sesión con Apple (Lógica pendiente)
                ElevatedButton.icon(
                  onPressed: () {
                    // Lógica para iniciar sesión con Apple
                  },
                  icon: FaIcon(FontAwesomeIcons.apple,
                      color: Theme.of(context).iconTheme.color),
                  label: Text(
                    'Continue with Apple',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Función para iniciar sesión con Google
  Future<void> _signInWithGoogle() async {
    try {
      // Inicio de sesión con Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null) {
        // Navegar a la pantalla para completar el registro
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompleteStaffRegistration(firebaseUser: user),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in failed: $e'),
        ),
      );
    }
  }
}
