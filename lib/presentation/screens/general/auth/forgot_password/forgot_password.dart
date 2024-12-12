import 'dart:convert';

import 'package:connectcare/presentation/screens/general/auth/verification/two_step_verification_screen.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';

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
  String userId = '';
  bool isStaff = false;

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
      final url = Uri.parse('$baseUrl/auth/emailAndId/$email');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (mounted && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userId = data['id'].toString();
        if (data['source'] == 'personal') {
          isStaff = true;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TwoStepVerificationScreen(
              purpose: 'recover',
              identifier: email,
              isSmsVerification: false,
              isStaff: isStaff,
              userId: userId,
            ),
          ),
        );
      } else {
        throw Exception('Email not found'.tr());
      }
    } catch (e) {
      showCustomSnackBar(context, 'Please enter valid credentials'.tr());
    }
  }

  Future<void> _recoverWithPhone(String phone) async {
    try {
      final url = Uri.parse('$baseUrl/auth/phoneAndId/$phone');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (mounted && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userId = data['id'].toString();
        if (data['source'] == 'personal') {
          isStaff = true;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TwoStepVerificationScreen(
              purpose: 'recover',
              identifier: phone,
              isSmsVerification: true,
              isStaff: isStaff,
              userId: userId,
            ),
          ),
        );
      } else {
        throw Exception('Phone number not found'.tr());
      }
    } catch (e) {
      _recoverFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recover password'.tr()),
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
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    _recover();
                  },
                  child: Text('Continue'.tr()),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _recoverFailed() {
    showCustomSnackBar(context, 'Please enter valid credentials'.tr());
  }

  void _focusScope() {
    FocusScope.of(context).requestFocus(FocusNode());
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
