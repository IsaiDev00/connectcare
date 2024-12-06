import 'dart:async';
import 'package:connectcare/main.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectcare/core/constants/constants.dart';
import 'dart:convert';
import 'package:connectcare/data/services/user_service.dart';

class TwoStepVerificationScreen extends StatefulWidget {
  final String identifier;
  final String purpose;
  final String? idPersonal;
  final String? firstName;
  final String? lastNamePaternal;
  final String? lastNameMaternal;
  final String? userType;
  final String? phoneNumber;
  final String? password;
  final String? email;
  final bool isStaff;
  final bool isSmsVerification;

  const TwoStepVerificationScreen({
    required this.identifier,
    required this.purpose,
    this.idPersonal,
    this.firstName,
    this.lastNamePaternal,
    this.lastNameMaternal,
    this.userType,
    this.phoneNumber,
    this.email,
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

  @override
  void initState() {
    super.initState();

    /*
    print("Verificando datos recibidos en TwoStepVerificationScreen:");
    print("Id personal: ${widget.idPersonal}");
    print("Nombre: ${widget.firstName}");
    print("Apellido Paterno: ${widget.lastNamePaternal}");
    print("Apellido Materno: ${widget.lastNameMaternal}");
    print("Correo Electrónico: ${widget.email}");
    print("Telefono: ${widget.phoneNumber}");
    print("Contraseña: ${widget.password}");
    print("Tipo de Usuario: ${widget.userType}");

    if (widget.email == null || widget.password == null) {
      throw Exception("Email o Password no están configurados correctamente.");
    }*/

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
                context, 'Código reenviado exitosamente por SMS.');
          }
        } else {
          throw Exception('Error al reenviar el código por SMS.');
        }
      } else {
        final resendEmailUrl = Uri.parse('$baseUrl/auth/resend-code');
        final response = await http.post(
          resendEmailUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': widget.identifier}),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            showCustomSnackBar(
                context, 'Código reenviado exitosamente al correo.');
          }
        } else {
          throw Exception('Error al reenviar el código por correo.');
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, 'Error al reenviar el código: $e');
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
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        widget.isSmsVerification
            ? '$baseUrl/auth/verify-sms-code'
            : '$baseUrl/auth/verify-code',
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
        if (widget.purpose == 'recover') {
          MyApp.nav.navigateTo(
            '/changePassword',
            arguments: widget.identifier,
          );
        } else if (widget.purpose == 'login') {
          await _navigation();
        } else if (widget.purpose == 'registration') {
          await _registerUser();
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
      // Validar que email y password no sean nulos
      if (widget.email == null || widget.password == null) {
        throw Exception(
            "Faltan datos esenciales para el registro (email o contraseña).");
      }

      final requestBody = {
        if (widget.isStaff) 'id_personal': widget.idPersonal,
        'nombre': widget.firstName,
        'apellido_paterno': widget.lastNamePaternal,
        'apellido_materno': widget.lastNameMaternal,
        'tipo': widget.userType ?? 'regular',
        'contrasena': widget.password,
        'auth_provider': widget.isSmsVerification ? 'phone' : 'email',
        if (widget.isSmsVerification) 'telefono': widget.phoneNumber,
        if (!widget.isSmsVerification) 'correo_electronico': widget.email,
      };

      final url =
          Uri.parse(widget.isStaff ? '$baseUrl/personal' : '$baseUrl/familiar');

      print("Cuerpo de la solicitud enviado al servidor:");
      print(requestBody);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("Respuesta del servidor:");
      print("Estado: ${response.statusCode}");
      print("Cuerpo: ${response.body}");

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        final userId = widget.isStaff
            ? responseData['id_personal']?.toString()
            : responseData['id']?.toString();
        final userType = responseData['tipo'] ?? 'regular';

        if (userId == null) {
          throw Exception("El servidor no devolvió un ID de usuario.");
        }

        final clues = widget.isStaff ? responseData['clues'] : null;
        await userService.saveUserSession(userId, userType, clues: clues);

        Navigator.pushReplacementNamed(context, '/dynamicWrapper');
      } else {
        throw Exception('Error en el registro: ${response.body}');
      }
    } catch (e) {
      print("Error en _registerUser: $e");
      _errorRegisteringUser(e);
    }
  }

  Future<void> _navigation() async {
    try {
      final url = Uri.parse(
          '$baseUrl/auth/user_by_email_or_phone/${widget.identifier}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final userType = userData['tipo']?.toLowerCase() ?? 'unknown';
        final clues = userData['clues'];
        final userId = userData['id']?.toString();

        if (userId == null) {
          throw Exception("User ID is missing in the server response");
        }

        await userService.saveUserSession(userId, userType, clues: clues);

        Navigator.pushReplacementNamed(context, '/dynamicWrapper');
      } else {
        throw Exception('Error fetching user data: ${response.body}');
      }
    } catch (e) {
      _errorDeterminigUserType(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificación de Código')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.isSmsVerification
                  ? 'Hemos enviado un código a tu número: ${widget.identifier}'
                  : 'Hemos enviado un código a tu correo: ${widget.identifier}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Código de Verificación',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyCode,
                    child: const Text('Verificar Código'),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isResendAllowed ? _resendCode : null,
              child: Text(
                _isResendAllowed
                    ? 'Reenviar Código'
                    : 'Reenviar Código ($_resendWaitTime)',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _invalidCode() {
    showCustomSnackBar(context, 'Código inválido o expirado');
  }

  void _errorVerifyingCode() {
    showCustomSnackBar(context, 'Error verificando el código');
  }

  void _errorRegisteringUser(e) {
    showCustomSnackBar(context, 'Error registering user: $e');
  }

  void _errorDeterminigUserType(Object e) {
    showCustomSnackBar(context, 'Error determining user type: $e');
  }
}
