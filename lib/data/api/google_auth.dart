import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await _auth.signInWithPopup(googleProvider);

        bool emailExists =
            await checkEmailExists(userCredential.user?.email ?? '');
        if (emailExists) {
          return Future.error(
              'Este correo ya está vinculado a otra cuenta en el sistema.');
        }

        return userCredential;
      } catch (e) {
        return Future.error('Google sign-in failed: $e');
      }
    } else {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

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
  }

  Future<bool> checkEmailExists(String email) async {
    var url = Uri.parse('$baseUrl/personal/email/$email');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
