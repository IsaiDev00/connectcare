import 'package:flutter/material.dart';
import 'package:connectcare/presentation/widgets/custom_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Función para iniciar sesión
  void _login() async {
    if (_formKey.currentState!.validate()) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      // Aquí puedes agregar la lógica para el inicio de sesión
      // Simulando un inicio de sesión exitoso
      Navigator.pushNamed(context, '/mainScreen');
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Login successful'),
        ),
      );
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
            key: _formKey, // Añadimos el GlobalKey al Form
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 30),

                // Campo de email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    // Validar que el campo no esté vacío
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // Validar formato de email
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
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
                    // Validar que el campo no esté vacío
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    // Validar que la contraseña tenga al menos 8 caracteres
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
                      // Navegar a la pantalla de "Forgot Password"
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
