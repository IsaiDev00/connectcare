import 'dart:async';
import 'package:flutter/material.dart';

class VerificationCode extends StatefulWidget {
  const VerificationCode({super.key});

  @override
  VerificationCodeState createState() => VerificationCodeState();
}

class VerificationCodeState extends State<VerificationCode> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  Timer?
      _timer; // El temporizador puede ser nulo, así que lo marcamos como opcional
  int _start = 20; // Contador de 20 segundos
  bool _isButtonDisabled =
      true; // El botón de re-envío está deshabilitado al inicio

  @override
  void initState() {
    super.initState();
    _startTimer(); // Iniciar el contador cuando la pantalla se carga
  }

  @override
  void dispose() {
    // Cancelar el temporizador solo si está activo
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    _codeController.dispose(); // Liberar el controlador de texto
    super.dispose();
  }

  // Función para iniciar el contador
  void _startTimer() {
    // Cancelar el temporizador previo si está activo
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        if (mounted) {
          setState(() {
            _isButtonDisabled =
                false; // Habilitar el botón cuando el contador llegue a 0
            _timer!.cancel();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _start--;
          });
        }
      }
    });
  }

  // Función para manejar el reenvío del código
  void _resendCode() {
    setState(() {
      _start = 20; // Reiniciar el contador
      _isButtonDisabled = true; // Deshabilitar el botón nuevamente
    });
    _startTimer(); // Reiniciar el contador

    // Aquí agregarías la lógica para re-enviar el código
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification code re-sent!')),
    );
  }

  // Función para manejar la validación del código
  void _verifyCode() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code verified!')),
      );
      // Aquí iría la lógica para proceder si el código es válido
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Verification Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Añadimos el GlobalKey al Form
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 30),

              // Instrucción para el usuario
              const Text(
                'Please enter the verification code sent to your email.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Campo para el código de verificación
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the verification code';
                  }
                  if (value.length != 6) {
                    return 'The code must be 6 digits long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Contador de tiempo
              Text(
                'Resend code in $_start seconds',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Botón de Re-send
              ElevatedButton(
                onPressed: _isButtonDisabled
                    ? null
                    : _resendCode, // Solo habilitado cuando el contador llegue a 0
                child: const Text('Re-send Code'),
              ),
              const SizedBox(height: 30),

              // Botón para confirmar el código
              ElevatedButton(
                onPressed: _verifyCode,
                child: const Text('Verify Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
