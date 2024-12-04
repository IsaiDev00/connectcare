import 'package:connectcare/main.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectcare/core/constants/constants.dart';
import 'dart:convert';

class TwoStepVerificationScreen extends StatefulWidget {
  final String identifier; // Puede ser correo o número de teléfono
  final bool isSmsVerification; // Diferencia entre correo y SMS

  const TwoStepVerificationScreen({
    required this.identifier,
    this.isSmsVerification = false,
    super.key,
  });

  @override
  State<TwoStepVerificationScreen> createState() =>
      _TwoStepVerificationScreenState();
}

class _TwoStepVerificationScreenState extends State<TwoStepVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Seleccionar endpoint en función del tipo de verificación
      final url = Uri.parse(widget.isSmsVerification
          ? '$baseUrl/auth/verify-sms-code'
          : '$baseUrl/auth/verify-code');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          widget.isSmsVerification ? 'phone' : 'email': widget.identifier,
          'code': _codeController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        MyApp.nav.navigateTo('/mainScreen');
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
