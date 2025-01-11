import 'package:connectcare/presentation/screens/general/auth/forgot_password/forgot_password.dart';
import 'package:connectcare/presentation/screens/general/auth/verification/two_step_verification_screen.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/api/google_auth.dart';
import 'package:connectcare/data/api/facebook_auth.dart';
import 'package:easy_localization/easy_localization.dart';

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
  String? userId;
  String? clues;
  String? patients;
  String? userType;
  String? status;
  String? schedule;
  String? services;
  bool isStaff = false;

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
        await _loginWithPhone(formattedPhoneNumber, password);
      }
    }
  }

  Future<void> _loginWithEmail(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/auth/loginWithEmail/$email');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'contrasena': password}),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        userId = userData['id'].toString();
        userType = userData['user_type'];
        clues = userData['clues'];
        patients = userData['patients'];
        status = userData['status'];
        schedule = userData['schedule'];
        services = userData['services'];

        if (userData['source'] == 'personal') {
          isStaff = true;
        }

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TwoStepVerificationScreen(
                userId: userId,
                userType: userType,
                clues: clues,
                patients: patients,
                isStaff: isStaff,
                purpose: 'login',
                identifier: email,
                isSmsVerification: false,
                status: status,
                schedule: schedule,
                services: services,
              ),
            ),
          );
        }
      } else {
        throw Exception('Email not found or invalid credentials'.tr());
      }
    } catch (e) {
      _loginFailed();
    }
  }

  Future<void> _loginWithPhone(String phone, String password) async {
    try {
      final url = Uri.parse('$baseUrl/auth/loginWithPhone/$phone');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'contrasena': password}),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        userId = userData['id'].toString();
        userType = userData['tipo'];
        clues = userData['clues'];
        patients = userData['patients'];
        status = userData['status'];
        schedule = userData['schedule'];
        services = userData['services'];
        if (userData['source'] == 'personal') {
          isStaff = true;
        }
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TwoStepVerificationScreen(
                userId: userId,
                userType: userType,
                clues: clues,
                patients: patients,
                purpose: 'login',
                isStaff: isStaff,
                identifier: phone,
                isSmsVerification: true,
                status: status,
                schedule: schedule,
                services: services,
              ),
            ),
          );
        }
      } else {
        throw Exception('Phone number not found or invalid credentials'.tr());
      }
    } catch (e) {
      _loginFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'.tr()),
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
                        decoration: InputDecoration(
                          labelText: 'Email Address'.tr(),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address'.tr();
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address (example@example.com)'
                                .tr();
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
                              decoration: InputDecoration(
                                labelText: 'Phone Number'.tr(),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number'.tr();
                                }
                                if (value.length != 10) {
                                  return 'Phone number must be exactly 10 digits'
                                      .tr();
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
                  decoration: InputDecoration(
                    labelText: 'Password'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPassword()));
                    },
                    child: Text(
                      'Forgot password?'.tr(),
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
                  child: Text('Login'.tr()),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("or".tr()),
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
                    isEmailMode
                        ? 'Continue with Phone'.tr()
                        : 'Continue with Email'.tr(),
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
                    'Continue with Facebook'.tr(),
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
                    'Continue with Google'.tr(),
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
    showCustomSnackBar(context, 'Please enter valid credentials'.tr());
  }

  void _focusScope() {
    FocusScope.of(context).requestFocus(FocusNode());
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> _loginWithGoogle() async {
    final GoogleAuthService googleAuthService = GoogleAuthService();

    try {
      await googleAuthService.loginWithGoogle(context);
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, e.toString());
      }
    }
  }

  Future<void> _loginWithFacebook() async {
    final FacebookAuthService facebookAuthService = FacebookAuthService();
    try {
      await facebookAuthService.loginWithFacebook(context);
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, e.toString());
      }
    }
  }
}
