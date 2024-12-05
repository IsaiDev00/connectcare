import 'dart:async';
import 'package:connectcare/main.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectcare/core/constants/constants.dart';
import 'dart:convert';

class TwoStepVerificationScreen extends StatefulWidget {
  final String identifier;
  final bool isSmsVerification;
  final String? verificationId;
  final int? resendToken;

  const TwoStepVerificationScreen({
    required this.identifier,
    this.isSmsVerification = false,
    this.verificationId,
    this.resendToken,
    super.key,
  });

  @override
  State<TwoStepVerificationScreen> createState() =>
      _TwoStepVerificationScreenState();
}

class _TwoStepVerificationScreenState extends State<TwoStepVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isResendAllowed = false;
  Timer? _resendTimer;
  int _resendWaitTime = 60;

  @override
  void initState() {
    super.initState();
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
        // Reenvío de código por correo
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
      if (widget.isSmsVerification) {
        final url = Uri.parse('$baseUrl/auth/verify-sms-code');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'phone': widget.identifier,
            'code': _codeController.text.trim(),
          }),
        );

        if (response.statusCode == 200) {
          MyApp.nav.navigateTo('/mainScreen');
        } else {
          _invalidCode();
        }
      } else {
        final url = Uri.parse('$baseUrl/auth/verify-code');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': widget.identifier,
            'code': _codeController.text.trim(),
          }),
        );

        if (response.statusCode == 200) {
          MyApp.nav.navigateTo('/mainScreen');
        } else {
          _invalidCode();
        }
      }
    } catch (e) {
      _errorVerifyingCode();
    } finally {
      setState(() {
        _isLoading = false;
      });
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
}
