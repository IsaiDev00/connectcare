import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:connectcare/presentation/screens/auth/complete_staff_registration.dart';
import 'package:http/http.dart' as http; // Importar para las consultas HTTP
import 'package:connectcare/core/constants/constants.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Verificar si el correo ya existe en la base de datos
  Future<bool> checkEmailExists(String email) async {
    var url = Uri.parse('$baseUrl/personal/email/$email');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return true; // El correo ya existe
    }
    return false; // El correo no existe
  }

  Future<UserCredential> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleUser == null) {
        return Future.error('Google sign-in canceled');
      }

      // Verificar si el correo ya existe en la base de datos
      bool emailExists = await checkEmailExists(googleUser.email);
      if (emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Este correo ya está vinculado a otra cuenta.')),
        );
        return Future.error('Correo ya registrado');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      try {
        // Intentar iniciar sesión con las credenciales de Google
        UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        User? user = userCredential.user;

        if (user != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CompleteStaffRegistration(firebaseUser: user),
            ),
          );
        }

        return userCredential; // Retorna UserCredential para usar en otras partes de la app
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // El correo ya está registrado con otro proveedor
          final email = googleUser.email;

          // Verificar qué métodos de inicio de sesión están asociados con este correo
          List<String> userSignInMethods =
              await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

          if (userSignInMethods.isNotEmpty) {
            if (userSignInMethods.contains('facebook.com')) {
              // El correo está vinculado a Facebook, iniciar sesión con Facebook
              // Aquí deberías manejar la vinculación con Facebook si fuera necesario,
              // similar a cómo lo haces en `facebook_auth.dart`.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Este correo ya está registrado con Facebook. Por favor, inicia sesión usando Facebook.')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Por favor, inicia sesión utilizando: ${userSignInMethods.first}')),
              );
            }
          }
          return Future.error('Correo ya registrado con otro proveedor');
        } else {
          rethrow;
        }
      }
    } catch (e) {
      if (!context.mounted) return Future.error('Context is not mounted');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in failed: $e'),
        ),
      );
      return Future.error(e); // Retornar un error si algo falla
    }
  }
}
