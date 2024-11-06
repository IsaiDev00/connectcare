import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String firstName;
  final String lastNamePaternal;
  final String lastNameMaternal;
  final String userType;
  final String id;
  final String email;

  const EmailVerificationScreen({
    required this.firstName,
    required this.lastNamePaternal,
    required this.lastNameMaternal,
    required this.userType,
    required this.id,
    required this.email,
    super.key,
  });

  @override
  EmailVerificationScreenState createState() => EmailVerificationScreenState();
}

class EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isEmailVerified = false;
  Timer? checkEmailVerifiedTimer;
  bool _isResendAllowed = false;
  // ignore: unused_field
  Timer? _resendTimer;
  int _resendWaitTime = 60;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
    _startCheckingVerificationStatus();
    _startResendTimer();
  }

  void _failedVerificationEmail(e) {
    showCustomSnackBar(context, "Failed send verification email");
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (!(user?.emailVerified ?? false)) {
        await user?.sendEmailVerification();
        setState(() {
          _isResendAllowed = false;
        });
        _startResendTimer();
      }
    } catch (e) {
      _failedVerificationEmail(e);
    }
  }

  @override
  void dispose() {
    checkEmailVerifiedTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startCheckingVerificationStatus() {
    checkEmailVerifiedTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        await FirebaseAuth.instance.currentUser?.reload();
        final user = FirebaseAuth.instance.currentUser;
        if (user?.emailVerified ?? false) {
          if (mounted) {
            setState(() {
              isEmailVerified = true;
            });
          }
          timer.cancel();
          await _registerUserInDatabase();
          _navigateToMainScreen();
        }
      },
    );
  }

  Future<void> _registerUserInDatabase() async {
    final url = Uri.parse('$baseUrl/personal');
    final requestBody = {
      'id_personal': widget.id,
      'nombre': widget.firstName,
      'apellido_paterno': widget.lastNamePaternal,
      'apellido_materno': widget.lastNameMaternal,
      'tipo': widget.userType,
      'correo_electronico': widget.email,
      'estatus': 'activo',
      'auth_provider': 'email',
      'firebase_uid': FirebaseAuth.instance.currentUser?.uid,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      _responseHandlerPost(response);
    } catch (e) {
      _errorRegistering(e);
    }
  }

  void _navigateToMainScreen() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/mainScreen', (route) => false);
  }

  void _startResendTimer() {
    _resendWaitTime = 60;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendWaitTime == 0) {
        if (mounted) {
          setState(() {
            _isResendAllowed = true;
          });
        }
        timer.cancel();
      } else {
        if (mounted) {
          setState(() {
            _resendWaitTime--;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'A verification email has been sent to your email address. Please check your inbox.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isResendAllowed ? _sendVerificationEmail : null,
              child: Text(
                _isResendAllowed
                    ? 'Resend Code'
                    : 'Resend Code ($_resendWaitTime)',
              ),
            ),
            const SizedBox(height: 20),
            if (!isEmailVerified) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  void _responseHandlerPost(response) {
    responseHandlerPost(response, context, "Registration successful",
        'Failed to register: ${response.body}');
  }

  void _errorRegistering(e) {
    showCustomSnackBar(context, "'Error registering user: $e'");
  }
}
