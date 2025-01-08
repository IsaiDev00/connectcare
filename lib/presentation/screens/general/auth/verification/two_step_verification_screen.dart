import 'dart:async';
import 'package:connectcare/presentation/screens/general/auth/forgot_password/change_password.dart';
import 'package:connectcare/presentation/screens/general/dynamic_wrapper.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectcare/core/constants/constants.dart';
import 'dart:convert';
import 'package:connectcare/data/services/user_service.dart';

class TwoStepVerificationScreen extends StatefulWidget {
  final String identifier;
  final String purpose;
  final String? userId;
  final String? firstName;
  final String? lastNamePaternal;
  final String? lastNameMaternal;
  final String? userType;
  final String? phoneNumber;
  final String? password;
  final String? email;
  final String? clues;
  final String? patients;
  final String? schedule;
  final String? status;
  final String? services;
  final bool isStaff;
  final bool isSmsVerification;

  const TwoStepVerificationScreen({
    required this.identifier,
    required this.purpose,
    this.userId,
    this.firstName,
    this.lastNamePaternal,
    this.lastNameMaternal,
    this.userType,
    this.phoneNumber,
    this.email,
    this.patients,
    this.schedule,
    this.status,
    this.services,
    this.clues,
    this.password,
    this.isStaff = false,
    this.isSmsVerification = false,
    super.key,
  });

  @override
  State<TwoStepVerificationScreen> createState() =>
      _TwoStepVerificationScreenState();
}

class _TwoStepVerificationScreenState extends State<TwoStepVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final userService = UserService();
  bool _isLoading = false;
  bool _isResendAllowed = false;
  Timer? _resendTimer;
  int _resendWaitTime = 60;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    /*print("Id personal: ${widget.userId}");
    print("Nombre: ${widget.firstName}");
    print("Apellido paterno: ${widget.lastNamePaternal}");
    print("Apellido materno: ${widget.lastNameMaternal}");
    print("Correo electrónico: ${widget.email}");
    print("Telefono: ${widget.phoneNumber}");
    print("Contraseña: ${widget.password}");
    print("Tipo de usuario: ${widget.userType}");*/

    /*if (widget.email == null || widget.password == null) {
      throw Exception("Email o password configurados correctamente");
    }*/
    _sendCode();
    _startResendTimer();
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

  Future<void> _sendCode() async {
    try {
      if (widget.isSmsVerification) {
        final sendUrl = Uri.parse('$baseUrl/auth/send-sms-code');
        final response = await http.post(
          sendUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone': widget.identifier}),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            showCustomSnackBar(context, 'Code successfully sent by SMS.'.tr());
          }
        } else {
          throw Exception('Error sending the code by SMS.'.tr());
        }
      } else {
        final sendEmailUrl = Uri.parse('$baseUrl/auth/send-email-code');
        final response = await http.post(
          sendEmailUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': widget.identifier}),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            showCustomSnackBar(
                context, 'Code successfully sent to the email.'.tr());
          }
        } else {
          throw Exception('Error sending the code by email.'.tr());
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, 'Error sending code'.tr());
      }
      setState(() {
        _isResendAllowed = true;
      });
    }
  }

  Future<void> _resendCode() async {
    if (!_isResendAllowed) return;

    setState(() {
      _isResendAllowed = false;
      _resendWaitTime = 60;
    });

    _startResendTimer();

    try {
      if (widget.isSmsVerification) {
        final resendUrl = Uri.parse('$baseUrl/auth/send-sms-code');
        final response = await http.post(
          resendUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone': widget.identifier}),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            showCustomSnackBar(
                context, 'Code successfully forwarded by SMS.'.tr());
          }
        } else {
          throw Exception('Error resending code via SMS.'.tr());
        }
      } else {
        final resendEmailUrl = Uri.parse('$baseUrl/auth/send-email-code');
        final response = await http.post(
          resendEmailUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': widget.identifier}),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            showCustomSnackBar(
                context, 'Code successfully forwarded to email.'.tr());
          }
        } else {
          throw Exception('Error resending the code by email.'.tr());
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, 'Error resending code'.tr());
      }
      setState(() {
        _isResendAllowed = true;
      });
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        widget.isSmsVerification
            ? '$baseUrl/auth/verify-sms-code'
            : '$baseUrl/auth/verify-email-code',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          widget.isSmsVerification ? 'phone' : 'email': widget.identifier,
          'code': _codeController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final urlDelete =
            Uri.parse('$baseUrl/auth/delete-code/${widget.identifier}');
        await http.delete(urlDelete);

        if (widget.purpose == 'recover') {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangePassword(
                  purpose: 'recover',
                  userId: widget.userId,
                  isStaff: widget.isStaff,
                ),
              ),
            );
          } else {
            if (mounted) {
              showCustomSnackBar(context, 'Failed to retrieve user ID'.tr());
            }
          }
        } else if (widget.purpose == 'login') {
          await _login();
        } else if (widget.purpose == 'registration') {
          await _registerUser();
        } else if (widget.purpose == 'editData') {
          await _editData();
        }
      } else {
        _invalidCode();
      }
    } catch (e) {
      _errorVerifyingCode();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerUser() async {
    try {
      final requestBody = {
        if (widget.isStaff) 'id_personal': widget.userId,
        'nombre': widget.firstName,
        'apellido_paterno': widget.lastNamePaternal,
        'apellido_materno': widget.lastNameMaternal,
        'tipo': widget.userType,
        'contrasena': widget.password,
        'auth_provider': widget.isSmsVerification ? 'phone' : 'email',
        if (widget.isSmsVerification) 'telefono': widget.phoneNumber,
        if (!widget.isSmsVerification) 'correo_electronico': widget.email,
      };

      final url =
          Uri.parse(widget.isStaff ? '$baseUrl/personal' : '$baseUrl/familiar');

      /*print("Cuerpo de la solicitud enviado al servidor:");
      print(requestBody);*/

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      /*print("Respuesta del servidor:");
      print("Estado: ${response.statusCode}");
      print("Cuerpo: ${response.body}");*/

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        final userId = widget.isStaff
            ? responseData['id_personal'].toString()
            : responseData['id_familiar'].toString();
        final userType = responseData['tipo'];

        await userService.saveUserSession(userId, userType);

        if (mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DynamicWrapper()),
              (route) => false);
        }
      } else {
        throw Exception('Registration error'.tr());
      }
    } catch (e) {
      //print("Error en _registerUser: $e");
      _errorRegisteringUser(e);
    }
  }

  Future<void> _login() async {
    try {
      if (widget.userId == null || widget.userType == null) {
        throw Exception('userId y userType no pueden ser nulos.'.tr());
      }
      await userService.saveUserSession(
        widget.userId!,
        widget.userType!,
        clues: widget.clues,
        patients: widget.patients,
        status: widget.status,
        schedule: widget.schedule,
        services: widget.services,
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DynamicWrapper()),
            (route) => false);
      }
    } catch (e) {
      _errorDeterminigUserType();
    }
  }

  Future<void> _editData() async {
    try {
      final userData = await userService.loadUserData();
      String? userId = userData['userId'];
      bool isStaff = false;

      if (widget.userType == 'administrator' ||
          widget.userType == 'nurse' ||
          widget.userType == 'stretcher bearer' ||
          widget.userType == 'doctor' ||
          widget.userType == 'human resources' ||
          widget.userType == 'social worker') {
        isStaff = true;
      }

      final String url;
      final Map<String, String> updateData;

      if (isStaff) {
        if (widget.isSmsVerification) {
          url = '$baseUrl/personal/update-phone/$userId';
          updateData = {'telefono': widget.identifier};
        } else {
          url = '$baseUrl/personal/update-email/$userId';
          updateData = {
            'correo_electronico': widget.identifier.trim().toLowerCase()
          };
        }
      } else {
        if (widget.isSmsVerification) {
          url = '$baseUrl/familiar/update-phone/$userId';
          updateData = {'telefono': widget.identifier};
        } else {
          url = '$baseUrl/familiar/update-email/$userId';
          updateData = {
            'correo_electronico': widget.identifier.trim().toLowerCase()
          };
        }
      }

      if (updateData.containsKey('telefono') &&
          updateData['telefono']!.isEmpty) {
        throw Exception('The phone number cannot be empty.'.tr());
      }
      if (updateData.containsKey('correo_electronico') &&
          updateData['correo_electronico']!.isEmpty) {
        throw Exception('The email cannot be empty.'.tr());
      }
      /*print(isStaff);
      print(widget.userType);
      print(widget.isSmsVerification);
      print(widget.identifier);
      print('URL: $url');
      print('Update Data: $updateData');*/

      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          showCustomSnackBar(
              context, 'Your information has been successfully updated.'.tr());
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DynamicWrapper()),
            (route) => false,
          );
        }
      } else {
        throw Exception('Failed to update data'.tr());
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, 'Error updating data'.tr());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Code Verification'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.isSmsVerification
                    ? 'sms_verification_message'.tr(args: [widget.identifier])
                    : 'email_verification_message'
                        .tr(args: [widget.identifier]),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Verification Code'.tr(),
                  border: const OutlineInputBorder(),
                  counterText: "",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'The code cannot be empty'.tr();
                  }
                  if (value.length != 6) {
                    return 'The code must be exactly 6 digits'.tr();
                  }
                  if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                    return 'The code must only contain numbers'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _verifyCode,
                      child: Text('Verify Code'.tr()),
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isResendAllowed ? _resendCode : null,
                child: Text(
                  _isResendAllowed
                      ? 'resend_code'.tr()
                      : 'resend_code_wait'
                          .tr(args: [_resendWaitTime.toString()]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _invalidCode() {
    showCustomSnackBar(context, 'Invalid or expired code'.tr());
  }

  void _errorVerifyingCode() {
    showCustomSnackBar(context, 'Error verifying code'.tr());
  }

  void _errorRegisteringUser(e) {
    showCustomSnackBar(context, 'Error registering user'.tr());
  }

  void _errorDeterminigUserType() {
    showCustomSnackBar(context, 'Error determining user type'.tr());
  }
}
