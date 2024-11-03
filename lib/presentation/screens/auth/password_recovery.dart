import 'package:connectcare/main.dart';
import 'package:flutter/material.dart';

class PasswordRecovery extends StatefulWidget {
  const PasswordRecovery({super.key});

  @override
  PasswordRecoveryState createState() => PasswordRecoveryState();
}

class PasswordRecoveryState extends State<PasswordRecovery> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  // Función para simular el envío de la recuperación de contraseña
  void _sendRecoveryRequest() async {
    if (_formKey.currentState!.validate()) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      // Mostrar el SnackBar y esperar hasta que desaparezca antes de navegar
      ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
          snackBarController = scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Password recovery email sent!'),
          duration: Duration(seconds: 2), // Duración del SnackBar
        ),
      );

      // Esperar a que el SnackBar desaparezca antes de navegar
      await snackBarController.closed;

      // Navegar a la pantalla de verificación de código una vez que el SnackBar ha desaparecido
      MyApp.nav.navigateTo('/verificationCode');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Recovery'),
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

                // Instrucción para el usuario
                const Text(
                  'Enter your email address to recover your password.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // Campo de email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Botón de envío de recuperación de contraseña
                ElevatedButton(
                  onPressed: _sendRecoveryRequest,
                  child: const Text('Send Recovery Email'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
