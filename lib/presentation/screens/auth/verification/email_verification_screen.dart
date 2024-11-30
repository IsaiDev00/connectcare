import 'dart:async';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:connectcare/main.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailVerificationScreen extends StatefulWidget {
  final String? firstName;
  final String? lastNamePaternal;
  final String? lastNameMaternal;
  final String? email;
  final String? userType;
  final String? id;
  final bool isStaff;
  final String purpose;
  final Map<String, dynamic>? userData;

  const EmailVerificationScreen({
    required this.email,
    required this.userType,
    required this.isStaff,
    required this.purpose,
    this.userData,
    this.firstName,
    this.lastNamePaternal,
    this.lastNameMaternal,
    this.id,
    super.key,
  });

  @override
  EmailVerificationScreenState createState() => EmailVerificationScreenState();
}

class EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isEmailVerified = false;
  Timer? checkEmailVerifiedTimer;
  bool _isResendAllowed = false;
  Timer? _resendTimer;
  int _resendWaitTime = 60;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
    _startCheckingVerificationStatus();
    _startResendTimer();
  }

  @override
  void dispose() {
    checkEmailVerifiedTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _resetResendTimer() {
    if (_resendTimer != null) {
      _resendTimer!.cancel();
    }
    setState(() {
      _isResendAllowed = false;
      _resendWaitTime = 60;
    });
    _startResendTimer();
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _resetResendTimer();
        _verificationEmailSent();
      }
    } catch (e) {
      _failedToSendVerificationEmail(e);
    }
  }

  void _startCheckingVerificationStatus() {
    checkEmailVerifiedTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        await FirebaseAuth.instance.currentUser?.reload();
        final user = FirebaseAuth.instance.currentUser;
        if (user?.emailVerified ?? false) {
          timer.cancel();
          _handleVerificationSuccess();
        }
      },
    );
  }

  void _startResendTimer() {
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendWaitTime == 0) {
        setState(() {
          _isResendAllowed = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _resendWaitTime--;
        });
      }
    });
  }

  Future<void> _handleVerificationSuccess() async {
    if (widget.purpose == 'registration') {
      await _registerUser();
    }

    try {
      final firebaseUid = FirebaseAuth.instance.currentUser?.uid;
      if (firebaseUid == null) throw Exception("User ID not found");

      await Future.delayed(const Duration(seconds: 2));

      final url = Uri.parse('$baseUrl/auth/firebase_uid/$firebaseUid');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final userType = userData['tipo'].toLowerCase();
        final assignedHospital = userData['clues'] != null;
        await SharedPreferencesService().saveUserId(firebaseUid.toString());

        if (!assignedHospital) {
          MyApp.nav.navigateTo('/mainScreenStaff');
          return;
        }

        switch (userType) {
          case 'medico':
          case 'doctor':
            MyApp.nav.navigateTo('/doctorHomeScreen');
            break;
          case 'enfermero':
          case 'nurse':
            MyApp.nav.navigateTo('/nurseHomeScreen');
            break;
          case 'camillero':
          case 'stretcher bearer':
            MyApp.nav.navigateTo('/stretcherBearerHomeScreen');
            break;
          case 'trabajo social':
          case 'social worker':
            MyApp.nav.navigateTo('/socialWorkerHomeScreen');
            break;
          case 'recursos humanos':
          case 'human resources':
            MyApp.nav.navigateTo('/humanResourcesHomeScreen');
            break;
          case 'familiar principal':
          case 'main family member':
            MyApp.nav.navigateTo('/mainFamiliMemberHomeScreen');
            break;
          case 'familiar regular':
          case 'regular family member':
            MyApp.nav.navigateTo('/regularFamilyMemberHomeScreen');
            break;
          case 'administrador':
          case 'administrator':
            MyApp.nav.navigateTo('/mainScreen');
            break;
          default:
            throw Exception('Unknown user type');
        }
      } else {
        throw Exception('Error fetching user data: ${response.body}');
      }
    } catch (e) {
      _errorDeterminigUserType(e);
    }
  }

  Future<void> _registerUser() async {
    try {
      final userData = {
        ...?widget.userData,
        'firebase_uid': FirebaseAuth.instance.currentUser?.uid,
        'correo_electronico': widget.email,
      };

      final url =
          Uri.parse(widget.isStaff ? '$baseUrl/personal' : '$baseUrl/familiar');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      _responseHandler(response);
    } catch (e) {
      _errorRegisteringUser(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Email')),
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
                    ? 'Resend Email'
                    : 'Resend Email ($_resendWaitTime)',
              ),
            ),
            const SizedBox(height: 20),
            if (!isEmailVerified) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  void _verificationEmailSent() {
    showCustomSnackBar(context, 'Verification email sent.');
  }

  void _failedToSendVerificationEmail(e) {
    showCustomSnackBar(context, 'Failed to send verification email: $e');
  }

  void _responseHandler(http.Response response) {
    responseHandlerPost(response, context, 'Registration successful.',
        'Failed to register: ${response.body}');
  }

  void _errorRegisteringUser(e) {
    showCustomSnackBar(context, 'Error registering user: $e');
  }

  void _errorDeterminigUserType(Object e) {
    showCustomSnackBar(context, 'Error determining user type: $e');
  }
}
