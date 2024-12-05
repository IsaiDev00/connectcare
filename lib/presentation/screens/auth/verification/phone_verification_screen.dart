import 'dart:async';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/api/phone_auth.dart';
import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/main.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectcare/core/models/phone_verification.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final PhoneVerification verificationModel;
  final int? resendToken;

  const PhoneVerificationScreen({
    required this.verificationModel,
    this.resendToken,
    super.key,
  });

  @override
  PhoneVerificationScreenState createState() => PhoneVerificationScreenState();
}

class PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isResendAllowed = false;
  Timer? _resendTimer;
  int _resendWaitTime = 60;
  String? currentVerificationId;
  int? _resendToken;
  bool _showVerificationError = false;
  final userService = UserService();

  @override
  void initState() {
    super.initState();
    currentVerificationId = widget.verificationModel.verificationId;
    _resendToken = widget.resendToken;
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty || _codeController.text.length != 6) {
      setState(() {
        _showVerificationError = true;
      });
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId:
            currentVerificationId ?? widget.verificationModel.verificationId,
        smsCode: _codeController.text,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      _handleVerificationSuccess();
    } catch (e) {
      _failedToVerifyCode(e);
    }
  }

  String? _getCodeError() {
    if (_codeController.text.isEmpty) {
      return 'Verification code cannot be empty';
    }
    if (_codeController.text.length != 6) {
      return 'Verification code must be exactly 6 digits';
    }
    return null;
  }

  Future<void> _handleVerificationSuccess() async {
    if (widget.verificationModel.purpose == 'registration') {
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
        await userService.saveUserSession(firebaseUid, userType);

        if (widget.verificationModel.isStaff && !assignedHospital) {
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
          case 'principal':
          case 'main':
            MyApp.nav.navigateTo('/mainFamiliMemberHomeScreen');
            break;
          case 'regular':
            MyApp.nav.navigateTo('/regularFamilyMemberHomeScreen');
            break;
          case 'administrador':
          case 'administrator':
            MyApp.nav.navigateTo('/mainScreen');
            break;
          default:
            throw Exception('Unknown user type: $userType');
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
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception("Firebase user is null. Cannot get UID.");
      }

      final requestBody = {
        'id_personal': widget.verificationModel.idPersonal,
        'nombre': widget.verificationModel.firstName,
        'apellido_paterno': widget.verificationModel.lastNamePaternal,
        'apellido_materno': widget.verificationModel.lastNameMaternal,
        'tipo': widget.verificationModel.userType,
        'telefono': widget.verificationModel.phoneNumber,
        'contrasena': widget.verificationModel.password,
        'firebase_uid': firebaseUser.uid,
        'auth_provider': 'phone',
        'estatus': 'activo',
      };

      final url = Uri.parse(
        widget.verificationModel.isStaff
            ? '$baseUrl/personal'
            : '$baseUrl/familiar',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        _responseHandlerPost(response);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      _errorRegisteringUser(e);
    }
  }

  void _startResendTimer() {
    _resendWaitTime = 60;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Verification')),
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
              decoration: InputDecoration(
                labelText: 'Verification Code',
                border: const OutlineInputBorder(),
                errorText: _showVerificationError ? _getCodeError() : null,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              onChanged: (_) {
                if (_showVerificationError) {
                  setState(() {});
                }
              },
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

  void _responseHandlerPost(response) {
    responseHandlerPost(response, context, 'Registration successful.',
        'Failed to register: ${response.body}');
  }

  void _failedToVerifyCode(e) {
    showCustomSnackBar(context, 'Failed to verify code: $e');
  }

  void _errorRegisteringUser(e) {
    showCustomSnackBar(context, 'Error registering user: $e');
  }

  void _sendVerificationCode() {
    if (!_isResendAllowed) {
      showCustomSnackBar(context, 'Please wait before trying again.');
      return;
    }

    setState(() {
      _isResendAllowed = false;
      _resendWaitTime = 60;
    });

    _startResendTimer();

    final phoneAuthService = PhoneAuthService();
    phoneAuthService.verifyPhoneNumber(
      phoneNumber: widget.verificationModel.phoneNumber,
      onCodeSent: (String verificationId) {
        setState(() {
          currentVerificationId = verificationId;
          _resendToken = phoneAuthService.resendToken;
        });

        showCustomSnackBar(context, 'Verification code resent successfully.');
      },
      onVerificationFailed: (String error) {
        showCustomSnackBar(
            context, 'Failed to resend verification code: $error');
        setState(() {
          _isResendAllowed = true;
        });
      },
      forceResendingToken: _resendToken,
    );
  }

  void _errorDeterminigUserType(Object e) {
    showCustomSnackBar(context, 'Error determining user type: $e');
  }
}
