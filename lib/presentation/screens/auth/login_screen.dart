import 'package:flutter/material.dart';
import 'package:connectcare/presentation/widgets/custom_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/services/shared_preferences_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      try {
        String identifier = _emailOrPhoneController.text.trim();
        var url = Uri.parse('$baseUrl/personal/emailOrPhone/$identifier');
        var response = await http.get(
          url,
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          var responseBody = jsonDecode(response.body);
          String userId = responseBody['id_personal']?.toString() ?? '';

          if (userId.isNotEmpty) {
            await _sharedPreferencesService.saveUserId(userId);

            var adminUrl = Uri.parse('$baseUrl/administrador/$userId');
            var adminResponse = await http.get(
              adminUrl,
              headers: {'Content-Type': 'application/json'},
            );

            if (adminResponse.statusCode == 200) {
              var adminData = jsonDecode(adminResponse.body);

              // Guardar si el usuario es administrador
              await _sharedPreferencesService.saveIsAdmin(true);

              // Guardar el clues en SharedPreferences
              String clues = adminData['clues'] ?? '';
              await _sharedPreferencesService.saveClues(clues);

              // Nueva consulta: Verificar si hay pisos registrados para el clues del administrador
              var pisoUrl = Uri.parse('$baseUrl/piso/clues/$clues');
              var pisoResponse = await http.get(
                pisoUrl,
                headers: {'Content-Type': 'application/json'},
              );

              // Redirige según la existencia de pisos
              if (pisoResponse.statusCode == 200) {
                var pisoData = jsonDecode(pisoResponse.body);
                if (pisoData.isNotEmpty) {
                  // Hay pisos registrados, ir a '/adminHomeScreen'
                  Navigator.pushNamed(context, '/adminHomeScreen');
                } else {
                  // No hay pisos registrados, ir a '/adminStartScreen'
                  Navigator.pushNamed(context, '/adminStartScreen');
                }
              } else if (pisoResponse.statusCode == 404) {
                // No hay pisos registrados, ir a '/adminStartScreen'
                Navigator.pushNamed(context, '/adminStartScreen');
              } else {
                throw Exception('Error al verificar los pisos');
              }
            } else if (adminResponse.statusCode == 404) {
              await _sharedPreferencesService.saveIsAdmin(false);
              Navigator.pushNamed(context, '/mainScreen');
            }

            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Login successful'),
              ),
            );
          } else {
            debugPrint('Error: User ID is empty');
          }
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Error: ${response.body}'),
            ),
          );
        }
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 30),

                // Campo de email o número de teléfono
                TextFormField(
                  controller: _emailOrPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Email or Phone',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email or phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Campo de contraseña
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
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Botón de texto "Forgot Password?"
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgotPassword');
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Botón de inicio de sesión
                CustomButton(
                  text: 'Login',
                  onPressed: _login,
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

                // Botón para iniciar sesión con Facebook
                ElevatedButton.icon(
                  onPressed: () {
                    // Lógica para iniciar sesión con Facebook
                  },
                  icon: Icon(
                    Icons.facebook,
                    color: brightness == Brightness.dark
                        ? Colors.white
                        : Colors.blue,
                  ),
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

                // Botón para iniciar sesión con Google
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
}
