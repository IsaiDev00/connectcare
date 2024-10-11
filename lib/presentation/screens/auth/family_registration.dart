import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectcare/data/repositories/table/familiar_repository.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:connectcare/services/shared_preferences_service.dart';

class FamilyRegistration extends StatefulWidget {
  const FamilyRegistration({super.key});

  @override
  FamilyRegistrationState createState() => FamilyRegistrationState();
}

class FamilyRegistrationState extends State<FamilyRegistration> {
  final _formKey = GlobalKey<FormState>();

  bool isEmailMode = false;

  // Controladores de texto para cada campo
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNamePaternalController =
      TextEditingController();
  final TextEditingController _lastNameMaternalController =
      TextEditingController();
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FamiliarRepository _familiarRepository = FamiliarRepository();
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

// Función para validar si el email ya está en uso
  Future<bool> _isEmailInUse(String email) async {
    try {
      final result = await _familiarRepository.isEmailInUse(email);
      return result;
    } catch (e) {
      debugPrint("Error al verificar el email: $e");
      return false;
    }
  }

// Función para validar si el teléfono ya está en uso
  Future<bool> _isPhoneInUse(String phone) async {
    try {
      final result = await _familiarRepository.isPhoneInUse(phone);
      return result;
    } catch (e) {
      debugPrint("Error al verificar el teléfono: $e");
      return false;
    }
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
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),

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
                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[¡@#\$%^&*~`+\-/<>,.]).{8,}$');
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

                      if (isEmailMode) {
                        bool emailInUse =
                            await _isEmailInUse(_emailOrPhoneController.text);
                        if (!mounted) return;
                        if (emailInUse) {
                          _showErrorSnackBar(scaffoldMessenger,
                              'This email is already in use');
                          return;
                        }
                      } else {
                        bool phoneInUse =
                            await _isPhoneInUse(_emailOrPhoneController.text);
                        if (!mounted) return;
                        if (phoneInUse) {
                          _showErrorSnackBar(scaffoldMessenger,
                              'This phone number is already in use');
                          return;
                        }
                      }

                      try {
                        // Insertar en la base de datos y obtener el ID generado
                        int idFamiliar = await _familiarRepository.insert({
                          'nombre': _firstNameController.text,
                          'apellido_paterno': _lastNamePaternalController.text,
                          'apellido_materno': _lastNameMaternalController.text,
                          'correo_electronico':
                              isEmailMode ? _emailOrPhoneController.text : null,
                          'telefono':
                              isEmailMode ? null : _emailOrPhoneController.text,
                          'contrasena': _passwordController.text,
                          'tipo': 'regular',
                        });

                        // Guardar el ID del usuario de forma local
                        await _sharedPreferencesService
                            .saveUserId(idFamiliar.toString());

                        _navigateToMainScreen();
                        _showSuccessSnackBar(
                            scaffoldMessenger, 'Registration successful');
                      } catch (e) {
                        _showErrorSnackBar(
                            scaffoldMessenger, 'Registration failed: $e');
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

                // Botón dinámico para alternar entre Email y Teléfono
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
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 10),

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
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 10),

                ElevatedButton.icon(
                  onPressed: () {
                    // Lógica para iniciar sesión con Google
                  },
                  icon: FaIcon(FontAwesomeIcons.google,
                      color: brightness == Brightness.dark
                          ? Colors.white
                          : Colors.red),
                  label: Text(
                    'Continue with Google',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
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

  void _navigateToMainScreen() {
    if (mounted) {
      Navigator.pushNamed(context, '/mainScreen');
    }
  }

  void _showSuccessSnackBar(
      ScaffoldMessengerState scaffoldMessenger, String message) {
    if (mounted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  void _showErrorSnackBar(
      ScaffoldMessengerState scaffoldMessenger, String message) {
    if (mounted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }
}
