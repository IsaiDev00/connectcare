import 'package:connectcare/main.dart';
import 'package:connectcare/presentation/screens/general/auth/verification/two_step_verification_screen.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/api/google_auth.dart';
import 'package:connectcare/data/api/facebook_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isEmailMode = false;
  String _completePhoneNumber = '';
  String _countryCode = "+52";

  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String identifier = _emailOrPhoneController.text.trim();
      String password = _passwordController.text.trim();

      if (isEmailMode) {
        await _loginWithEmail(identifier, password);
      } else {
        _completePhoneNumber = '$_countryCode${_phoneNumberController.text}';
        String formattedPhoneNumber = _completePhoneNumber.startsWith('+')
            ? _completePhoneNumber
            : '+$_countryCode${_phoneNumberController.text}';
        print(formattedPhoneNumber + " " + password);
        await _loginWithPhone(formattedPhoneNumber, password);
      }
    }
  }

  Future<void> _loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;

      if (user != null) {
        final url = Uri.parse('$baseUrl/auth/send-code');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        );

        if (mounted && response.statusCode == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TwoStepVerificationScreen(
                identifier: email,
                isSmsVerification: false,
              ),
            ),
          );
        } else {
          _errorSendingCode();
        }
      }
    } catch (e) {
      throw Exception('Login failed with email: $e');
    }
  }

  Future<void> _loginWithPhone(String phone, String password) async {
    try {
      print('Iniciando el login con el número: $phone');

      if (!phone.startsWith('+')) {
        print('Error: El número no incluye el código internacional.');
        throw Exception('El número debe incluir el código internacional.');
      }

      final url = Uri.parse('$baseUrl/auth/phoneAndPassword/$phone');
      print('Haciendo GET request a: $url');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      print(
          'Respuesta del servidor: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        print('Número encontrado, verificando contraseña...');
        final userData = jsonDecode(response.body);
        print('Datos recibidos: $userData');

        if (userData['contrasena'] != password) {
          print('Error: Contraseña inválida');
          throw Exception('Contraseña inválida');
        }

        final sendCodeUrl = Uri.parse('$baseUrl/auth/send-sms-code');
        print('Haciendo POST request a: $sendCodeUrl');

        final sendCodeResponse = await http.post(
          sendCodeUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone': phone}),
        );
        print(
            'Respuesta al enviar código de verificación: ${sendCodeResponse.statusCode} - ${sendCodeResponse.body}');

        if (mounted && sendCodeResponse.statusCode == 200) {
          print(
              'Código de verificación enviado correctamente. Navegando a TwoStepVerificationScreen.');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TwoStepVerificationScreen(
                identifier: phone,
                isSmsVerification: true,
              ),
            ),
          );
        } else {
          print('Error al enviar el código de verificación por SMS.');
          throw Exception('Error al enviar el código de verificación por SMS.');
        }
      } else {
        print('Error: Teléfono no encontrado o credenciales inválidas.');
        throw Exception(
            'Número de teléfono no encontrado o credenciales inválidas');
      }
    } catch (e) {
      print('Error atrapado en el catch: $e');
      _loginFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 30),
                isEmailMode
                    ? TextFormField(
                        controller: _emailOrPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address (example@example.com)';
                          }
                          return null;
                        },
                      )
                    : Row(
                        children: [
                          CountryCodePicker(
                            initialSelection: 'MX',
                            favorite: ['+52', 'MX'],
                            onChanged: (country) {
                              setState(() {
                                _countryCode = country.dialCode ?? "+52";
                              });
                            },
                            dialogBackgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            textStyle: Theme.of(context).textTheme.bodyLarge,
                            dialogTextStyle:
                                Theme.of(context).textTheme.bodyLarge,
                            searchStyle: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                if (value.length != 10) {
                                  return 'Phone number must be exactly 10 digits';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgotPassword');
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    _login();
                  },
                  child: const Text('Login'),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("or"),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isEmailMode = !isEmailMode;
                      _emailOrPhoneController.clear();
                      FocusScope.of(context).requestFocus(FocusNode());
                      Future.delayed(Duration(milliseconds: 50), () {
                        _focusScope();
                      });
                    });
                  },
                  icon: Icon(
                    isEmailMode ? Icons.phone : Icons.email_outlined,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  label: Text(
                    isEmailMode ? 'Continue with Phone' : 'Continue with Email',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    _loginWithFacebook();
                  },
                  icon: Icon(
                    Icons.facebook,
                    color: brightness == Brightness.dark
                        ? Colors.white
                        : Colors.blue,
                  ),
                  label: Text(
                    'Continue with Facebook',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    _loginWithGoogle();
                  },
                  icon: FaIcon(FontAwesomeIcons.google,
                      color: brightness == Brightness.dark
                          ? Colors.white
                          : Colors.red),
                  label: Text(
                    'Continue with Google',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _loginFailed() {
    showCustomSnackBar(context, 'Please enter valid credentials');
  }

  void _errorSendingCode() {
    showCustomSnackBar(context, 'Error sending code');
  }

  void _focusScope() {
    FocusScope.of(context).requestFocus(FocusNode());
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleAuthService googleAuthService = GoogleAuthService();
      final userCredential = await googleAuthService.loginWithGoogle();

      if (userCredential != null) {
        MyApp.nav.navigateTo('/mainScreen');
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, e.toString());
      }
    }
  }

  Future<void> _loginWithFacebook() async {
    try {
      final FacebookAuthService facebookAuthService = FacebookAuthService();
      final String? error = await facebookAuthService.loginWithFacebook();

      if (error == null) {
        MyApp.nav.navigateTo('/mainScreen');
      } else if (mounted) {
        showCustomSnackBar(context, error);
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
            context, 'Error de inicio de sesión con Facebook: $e');
      }
    }
  }
}
