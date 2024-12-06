import 'package:connectcare/presentation/screens/general/auth/verification/two_step_verification_screen.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  ForgotPasswordState createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  bool isEmailMode = false;
  String _completePhoneNumber = '';
  String _countryCode = "+52";

  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  Future<void> _recover() async {
    if (_formKey.currentState!.validate()) {
      String identifier = _emailOrPhoneController.text.trim();

      if (isEmailMode) {
        await _recoverWithEmail(identifier);
      } else {
        _completePhoneNumber = '$_countryCode${_phoneNumberController.text}';
        String formattedPhoneNumber = _completePhoneNumber.startsWith('+')
            ? _completePhoneNumber
            : '+$_countryCode${_phoneNumberController.text}';
        await _recoverWithPhone(formattedPhoneNumber);
      }
    }
  }

  Future<void> _recoverWithEmail(String email) async {
    try {
      final url = Uri.parse('$baseUrl/auth/email/$email');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
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
                purpose: 'recover',
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
      throw Exception('Recover failed with email: $e');
    }
  }

  Future<void> _recoverWithPhone(String phone) async {
    try {
      final url = Uri.parse('$baseUrl/auth/phoneAndPassword/$phone');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final sendCodeUrl = Uri.parse('$baseUrl/auth/send-sms-code');
        final sendCodeResponse = await http.post(
          sendCodeUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone': phone}),
        );

        if (mounted && sendCodeResponse.statusCode == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TwoStepVerificationScreen(
                purpose: 'recover',
                identifier: phone,
                isSmsVerification: true,
              ),
            ),
          );
        } else {
          throw Exception('Error sending verification code via SMS.');
        }
      } else {
        throw Exception('Phone number not found');
      }
    } catch (e) {
      _recoverFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recover password'),
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
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    _recover();
                  },
                  child: const Text('Continue'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _recoverFailed() {
    showCustomSnackBar(context, 'Please enter valid credentials');
  }

  void _errorSendingCode() {
    showCustomSnackBar(context, 'Error sending code');
  }

  void _focusScope() {
    FocusScope.of(context).requestFocus(FocusNode());
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
