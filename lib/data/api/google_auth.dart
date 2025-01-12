import 'dart:convert';

import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/presentation/screens/general/dynamic_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:connectcare/core/constants/constants.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final userService = UserService();

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      return Future.error('Google sign-in canceled');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    try {
      bool emailExists = await checkEmailExists(googleUser.email);
      if (emailExists) {
        return Future.error(
            'Este correo ya está vinculado a otra cuenta en el sistema.');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        return Future.error(
            'Este correo ya está registrado con otro proveedor. Por favor, usa el método de inicio de sesión correcto.');
      }
      rethrow;
    } catch (e) {
      return Future.error('Google sign-in failed: $e');
    }
  }

  Future<String?> loginWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      return Future.error('Inicio de sesión cancelado por el usuario');
    }

    await googleUser.authentication;

    try {
      final String cleanEmail = googleUser.email.trim();

      final url = Uri.parse('$baseUrl/auth/loginWithProvider/$cleanEmail');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 404) {
        return Future.error(
            'Este correo no está registrado. Por favor, regístrate primero.');
      }

      if (response.statusCode != 200) {
        throw Exception('Error al verificar el correo');
      }

      final userData = jsonDecode(response.body);
      String userId = userData['id'].toString();
      String? userType = userData['tipo'];
      String? clues = userData['clues'];
      String? patients = userData['patients'];
      String? status = userData['status'];
      String? schedule = userData['schedule'];
      String? services = userData['services'];

      if (userType == null || userType == '') {
        await userService.saveUserSession(
          userId,
          clues: clues,
          patients: patients,
          status: status,
          schedule: schedule,
          services: services,
        );
      } else {
        await userService.saveUserSession(
          userId,
          userType: userType,
          clues: clues,
          patients: patients,
          status: status,
          schedule: schedule,
          services: services,
        );
      }
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DynamicWrapper()),
          (route) => false,
        );
      }

      return 'Usuario logueado con éxito';
    } catch (e) {
      return Future.error('Error en el inicio de sesión con Google: $e');
    }
  }
}

Future<bool> checkEmailExists(String email) async {
  var url = Uri.parse('$baseUrl/auth/emailAndId/$email');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    return true;
  }
  return false;
}
