import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:connectcare/presentation/screens/auth/complete_staff_registration.dart';
import 'package:connectcare/data/api/google_auth.dart';
import 'package:http/http.dart' as http;
import 'package:connectcare/core/constants/constants.dart'; // Asegúrate de tener la URL base

class FacebookAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleAuthService _googleAuthService =
      GoogleAuthService(); // Instancia para la vinculación de cuentas

  // Función para verificar si un correo ya existe en la base de datos
  Future<bool> checkEmailExists(String email) async {
    final url = Uri.parse('$baseUrl/personal/email/$email');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return true; // El correo ya existe
    } else if (response.statusCode == 404) {
      return false; // El correo no existe
    } else {
      throw Exception('Error al verificar el correo: ${response.body}');
    }
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(result.accessToken!.tokenString);

        // Obtener los datos del usuario de Facebook para obtener el correo electrónico
        final userData = await FacebookAuth.instance.getUserData();
        final String? email = userData['email'];

        // Validar si obtenemos el correo de Facebook
        if (email == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'No se pudo obtener el correo electrónico de Facebook')),
          );
          return;
        }

        // Validar si el correo ya existe en la base de datos
        bool emailExists = await checkEmailExists(email);
        if (emailExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Este correo ya está registrado en otra cuenta.')),
          );
          return;
        }

        try {
          // Intentar iniciar sesión con las credenciales de Facebook en Firebase
          UserCredential userCredential =
              await _auth.signInWithCredential(facebookAuthCredential);

          if (!context.mounted) return;

          User? user = userCredential.user;
          if (user != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CompleteStaffRegistration(firebaseUser: user),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Error al obtener el usuario de Facebook')),
            );
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            // El correo ya está registrado con otro proveedor
            final pendingCredential = e.credential;

            // Verificar qué métodos de inicio de sesión están asociados con este correo
            List<String> userSignInMethods =
                await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

            if (userSignInMethods.isNotEmpty) {
              if (userSignInMethods.contains('google.com')) {
                // El correo está vinculado a Google, iniciar sesión con Google
                _googleAuthService
                    .signInWithGoogle(context)
                    .then((googleUserCredential) {
                  // Vincular las credenciales de Facebook con la cuenta existente de Google
                  googleUserCredential.user
                      ?.linkWithCredential(pendingCredential!);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cuentas vinculadas con éxito')),
                  );
                  Navigator.pushNamed(context, '/mainScreen');
                }).catchError((error) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error al vincular cuentas: $error')),
                  );
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Por favor, inicia sesión utilizando: ${userSignInMethods.first}')),
                );
              }
            } else {
              // No hay métodos asociados con este correo, permite continuar el registro
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompleteStaffRegistration(
                      firebaseUser: FirebaseAuth.instance.currentUser!),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Error al iniciar sesión con Facebook: $e')),
            );
          }
        }
      } else if (result.status == LoginStatus.cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inicio de sesión con Facebook cancelado')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión con Facebook')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de autenticación: $e')),
      );
    }
  }
}
