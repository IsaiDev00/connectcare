import 'dart:convert';

import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/presentation/screens/general/dynamic_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'package:connectcare/core/constants/constants.dart';

class FacebookAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final userService = UserService();

  Future<String?> signInWithFacebook() async {
    await FacebookAuth.instance.logOut();
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(result.accessToken!.tokenString);

        final userData = await FacebookAuth.instance.getUserData();
        final String? email = userData['email'];

        if (email == null) {
          return 'No se pudo obtener el correo electrónico de Facebook';
        }

        bool emailExists = await checkEmailExists(email);
        if (emailExists) {
          return 'Este correo ya está registrado en otra cuenta en el sistema.';
        }

        try {
          UserCredential userCredential =
              await _auth.signInWithCredential(facebookAuthCredential);
          return userCredential.user != null
              ? null
              : 'Error al obtener el usuario de Facebook';
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            return 'Este correo ya está registrado con otro proveedor. Por favor, usa el método de inicio de sesión correcto.';
          }
          return 'Error al iniciar sesión en Firebase: $e';
        }
      } else if (result.status == LoginStatus.cancelled) {
        return 'Inicio de sesión con Facebook cancelado';
      } else {
        return 'Error al iniciar sesión con Facebook';
      }
    } catch (e) {
      return 'Error de autenticación con Facebook: $e';
    }
  }

  Future<String?> loginWithFacebook(BuildContext context) async {
    await FacebookAuth.instance.logOut();
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(result.accessToken!.tokenString);

        final userData = await FacebookAuth.instance.getUserData();
        final String? email = userData['email'];

        if (email == null || email.isEmpty) {
          return 'No se pudo obtener el correo electrónico de Facebook. Asegúrate de que tu cuenta tiene un correo asociado y otorga los permisos necesarios.';
        }

        try {
          await _auth.signInWithCredential(facebookAuthCredential);

          final String cleanEmail = email.trim();
          final url = Uri.parse('$baseUrl/auth/loginWithProvider/$cleanEmail');
          final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
          );

          if (response.statusCode == 404) {
            return 'Este correo no está registrado. Por favor, regístrate primero.';
          }

          if (response.statusCode != 200) {
            throw Exception('Error al verificar el correo.');
          }

          final userDataQuery = jsonDecode(response.body);
          String userId = userDataQuery['id'].toString();
          String userType = userDataQuery['tipo'];
          String? clues = userDataQuery['clues'];
          String? patients = userDataQuery['patients'];

          await userService.saveUserSession(
            userId,
            userType,
            clues: clues,
            patients: patients,
          );

          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DynamicWrapper()),
              (route) => false,
            );
          }

          return 'Usuario logueado con éxito';
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            return 'Este correo ya está registrado con otro proveedor. Por favor, inicia sesión usando el proveedor correcto.';
          } else {
            return 'Error al iniciar sesión con Facebook: ${e.message}';
          }
        }
      } else if (result.status == LoginStatus.cancelled) {
        return 'Inicio de sesión con Facebook cancelado';
      } else {
        return 'Error al iniciar sesión con Facebook';
      }
    } catch (e) {
      return 'Error al iniciar sesión con Facebook: $e';
    }
  }
}

Future<bool> checkEmailExists(String email) async {
  final url = Uri.parse('$baseUrl/auth/emailAndId/$email');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return true;
  } else if (response.statusCode == 404) {
    return false;
  } else {
    throw Exception('Error al verificar el correo: ${response.body}');
  }
}
