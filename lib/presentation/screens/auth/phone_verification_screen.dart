import 'dart:async';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PhoneVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final String password;
  final String id;
  final String firstName;
  final String lastNamePaternal;
  final String lastNameMaternal;
  final String userType;

  const PhoneVerificationScreen({
    required this.verificationId,
    required this.phoneNumber,
    required this.password,
    required this.id,
    required this.firstName,
    required this.lastNamePaternal,
    required this.lastNameMaternal,
    required this.userType,
    super.key,
  });

  @override
  PhoneVerificationScreenState createState() => PhoneVerificationScreenState();
}

class PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ignore: unused_field
  String? _verificationId;
  bool _isResendAllowed = false;
  // ignore: unused_field
  Timer? _resendTimer;
  int _resendWaitTime = 60;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _codeController.text,
      );
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _registerUser();
      }
    } on FirebaseAuthException catch (e) {
      _failedCode(e);
    }
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

  Future<void> _sendVerificationCode() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _isResendAllowed = false;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        if (mounted) {
          _registerUser();
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint('Error al enviar SMS: ${e.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send SMS: ${e.message}')),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        debugPrint('SMS enviado correctamente al número ${widget.phoneNumber}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification code sent.')),
          );
          _startResendTimer();
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _registerUser() async {
    try {
      final url = Uri.parse('$baseUrl/personal');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_personal': widget.id,
          'nombre': widget.firstName,
          'apellido_paterno': widget.lastNamePaternal,
          'apellido_materno': widget.lastNameMaternal,
          'tipo': widget.userType,
          'telefono': widget.phoneNumber,
          'contrasena': widget.password,
          'estatus': 'activo',
          'auth_provider': 'phone',
          'firebase_uid': FirebaseAuth.instance.currentUser?.uid,
        }),
      );

      _responseHandlerWithNavigation(response);
    } catch (e) {
      _errorRegistering(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter the SMS code sent to your phone',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyCode,
              child: const Text('Verify'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isResendAllowed ? _sendVerificationCode : null,
              child: Text(
                _isResendAllowed
                    ? 'Resend Code'
                    : 'Resend Code ($_resendWaitTime)',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _failedCode(e) {
    showCustomSnackBar(context, 'Failed to verify code: ${e.message}');
  }

  void _errorRegistering(e) {
    showCustomSnackBar(context, "'Error registering user: $e'");
  }

  void _responseHandlerWithNavigation(response) {
    if (response.statusCode == 201) {
      showCustomSnackBar(context, 'Registration successful');
      Navigator.pushReplacementNamed(context, '/mainScreen');
    } else {
      showCustomSnackBar(context, 'Failed to register: ${response.body}');
    }
  }
}
