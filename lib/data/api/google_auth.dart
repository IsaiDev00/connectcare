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

  Future<String?> loginWithGoogle(context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      return Future.error('Inicio de sesión cancelado por el usuario');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    try {
      bool emailExists = await checkEmailExists(googleUser.email);
      if (!emailExists) {
        return Future.error(
            'Este correo no está registrado. Por favor, regístrate primero.');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      final String cleanEmail = googleUser.email.trim();
      final url2 = Uri.parse('$baseUrl/auth/loginWithEmail/$cleanEmail');
      final response2 = await http.get(
        url2,
        headers: {'Content-Type': 'application/json'},
      );

      if (response2.statusCode == 200) {
        try {
          final userDataQuery = jsonDecode(response2.body);
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

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DynamicWrapper()),
            (route) => false,
          );
          return 'Usuario logueado con exito';
        } catch (e) {
          throw Exception('Error al procesar la respuesta del servidor.');
        }
      } else {
        throw Exception('Email no encontrado o credenciales inválidas');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        return Future.error(
            'Este correo ya está registrado con otro proveedor. Por favor, inicia sesión usando el proveedor correcto.');
      }
      return Future.error('Error al iniciar sesión con Google: ${e.message}');
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
