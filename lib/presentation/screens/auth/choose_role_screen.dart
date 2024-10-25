import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

class ChooseRoleScreen extends StatelessWidget {
  const ChooseRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Cambiar el estilo de la barra de estado según el tema
    var brightness = Theme.of(context).brightness;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Fondo transparente
      statusBarIconBrightness: brightness == Brightness.dark
          ? Brightness.light // Íconos blancos en modo oscuro
          : Brightness.dark, // Íconos negros en modo claro
    ));

    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Fondo basado en el tema
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context)
            .scaffoldBackgroundColor, // Fondo basado en el tema
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo o icono de la app
            Center(
              child: Image.asset(
                'assets/images/cuidado-de-la-salud.png',
                height: 150,
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Welcome to ConnectCare',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Create an account to get started.',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Navegar a la pantalla de registro del personal hospitalario
                Navigator.pushNamed(context, '/hospitalStaffRegistration');
              },
              child: Text('Hospital staff'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navegar a la pantalla de registro de familiares
                Navigator.pushNamed(context, '/familyRegistration');
              },
              child: Text('Familiar'),
            ),
            SizedBox(height: 30),
            // Texto de "¿Ya tienes una cuenta?" y enlaces a términos y condiciones
            Column(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/loginScreen');
                  },
                  child: Text(
                    'Already have an account? Log in',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'By continuing, you agree to ConnectCare\'s ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: 'Terms and Conditions',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navegar a la pantalla de Términos y Condiciones
                            Navigator.pushNamed(context, '/termsAndConditions');
                          },
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navegar a la pantalla de Política de Privacidad
                            Navigator.pushNamed(context,
                                '/privacyPolicy'); // Esta ruta debe coincidir
                          },
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
