import 'package:flutter/material.dart';
import 'package:connectcare/presentation/widgets/custom_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http; // Importa el paquete http
import 'dart:convert'; // Para convertir JSON
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

  // Define el URL base de tu backend
  final String _baseUrl =
      'http://35.188.80.9:8080'; // Cambia esto por el URL de tu backend

  // Función para iniciar sesión utilizando el backend
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      try {
        // Construye el cuerpo de la solicitud
        Map<String, dynamic> requestBody = {
          'identifier': _emailOrPhoneController.text.trim(),
          'contrasena': _passwordController.text.trim(),
        };

        // Realiza la solicitud POST al backend
        var url = Uri.parse('$_baseUrl/staff/login');
        var response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        // Mostrar la respuesta del servidor para depurar
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Server response: ${response.body}'),
          ),
        );

        if (response.statusCode == 200) {
          // Inicio de sesión exitoso
          var responseBody = jsonDecode(response.body);
          // Asegúrate de que el campo 'user' existe y luego accede a 'id_personal'
          if (responseBody != null && responseBody['user'] != null) {
            debugPrint('Full Response: $responseBody');

            // Acceder al campo 'id_personal' dentro del objeto 'user'
            String userId =
                responseBody['user']['id_personal']?.toString() ?? '';

            if (userId.isEmpty) {
              debugPrint('Error: User ID is empty');
            } else {
              debugPrint('User ID: $userId');
              // Guardar el ID del usuario en SharedPreferences
              await _sharedPreferencesService.saveUserId(userId);
            }
          } else {
            debugPrint('Error: Response does not contain user information');
          }

          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Login successful'),
            ),
          );
          Navigator.pushNamed(context, '/mainScreen');
        } else {
          // Error en el inicio de sesión, intentar decodificar el JSON o mostrar el mensaje directamente
          try {
            var responseBody = jsonDecode(response.body);
            String errorMessage =
                responseBody['error'] ?? 'Invalid email/phone or password';
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
        // Error durante el proceso de inicio de sesión (red, JSON, etc.)
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
                const SizedBox(height: 10),

                // Botón para iniciar sesión con Apple
                ElevatedButton.icon(
                  onPressed: () {
                    // Lógica para iniciar sesión con Apple
                  },
                  icon: Icon(
                    Icons.apple,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  label: Text(
                    'Continue with Apple',
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
