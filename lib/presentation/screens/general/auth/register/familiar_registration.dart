import 'package:connectcare/presentation/screens/general/auth/register/complete_familiar_registration.dart';
import 'package:connectcare/presentation/screens/general/auth/verification/two_step_verification_screen.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:connectcare/data/api/google_auth.dart';
import 'package:connectcare/data/api/facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';

class FamiliarRegistration extends StatefulWidget {
  const FamiliarRegistration({super.key});

  @override
  FamiliarRegistrationState createState() => FamiliarRegistrationState();
}

class FamiliarRegistrationState extends State<FamiliarRegistration> {
  final _formKey = GlobalKey<FormState>();

  bool isEmailMode = false;
  String _completePhoneNumber = '';
  String _countryCode = "+52";
  // ignore: unused_field
  int? _resendToken;

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNamePaternalController =
      TextEditingController();
  final TextEditingController _lastNameMaternalController =
      TextEditingController();
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final FacebookAuthService _facebookAuthService = FacebookAuthService();

  Future<bool> checkEmailExists(String email) async {
    var url = Uri.parse('$baseUrl/auth/emailAndId/$email');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> checkPhoneExists(String phone) async {
    var url = Uri.parse('$baseUrl/auth/phoneAndId/$phone');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: Text('Register with ConnectCare'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:
              brightness == Brightness.dark ? Colors.transparent : Colors.white,
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: brightness == Brightness.dark
              ? Brightness.dark
              : Brightness.light,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _lastNamePaternalController,
                  decoration: InputDecoration(
                    labelText: 'Last Name (Paternal)'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your paternal last name'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _lastNameMaternalController,
                  decoration: InputDecoration(
                    labelText: 'Last Name (Maternal)'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your maternal last name'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
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
                    errorMaxLines: 3,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password'.tr();
                    }
                    final passwordRegex = RegExp(
                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#%^&*~`+\-/<>,.]).{8,}$');
                    if (!passwordRegex.hasMatch(value)) {
                      return 'Password must be at least 8 characters and include uppercase, lowercase, numbers, and symbols ¡@#%^&*~`+-/<>,.'
                          .tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text ||
                        value == null ||
                        value.isEmpty) {
                      return 'Passwords do not match'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      if (isEmailMode) {
                        bool emailExists = await checkEmailExists(
                            _emailOrPhoneController.text);
                        if (emailExists) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                                content: Text('Email is already in use'.tr())),
                          );
                          return;
                        }
                        _emailNavigator();
                      } else {
                        _completePhoneNumber =
                            '$_countryCode${_phoneNumberController.text}';

                        bool phoneExists =
                            await checkPhoneExists(_completePhoneNumber);
                        if (phoneExists) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Phone number is already in use'.tr())),
                          );
                          return;
                        }
                        _phoneNavigator();
                      }
                    }
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
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _registerWithFacebook();
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.facebook,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.blue,
                  ),
                  label: Text(
                    'Continue with Facebook'.tr(),
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
                  onPressed: () async {
                    await _registerWithGoogle();
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.google,
                    color: brightness == Brightness.dark
                        ? Colors.white
                        : Colors.red,
                  ),
                  label: Text(
                    'Continue with Google'.tr(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBarMessage(String message) {
    showCustomSnackBar(context, message);
  }

  Future<void> _registerWithGoogle() async {
    try {
      final userCredential = await _googleAuthService.signInWithGoogle();
      if (mounted && userCredential != null && userCredential.user != null) {
        final firebaseUser = userCredential.user!;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CompleteFamiliarRegistration(firebaseUser: firebaseUser)));
      } else {
        _showSnackBarMessage('Failed to retrieve Google user.'.tr());
      }
    } catch (e) {
      _showSnackBarMessage(e.toString());
    }
  }

  Future<void> _registerWithFacebook() async {
    final String? errorMessage;
    try {
      errorMessage = await _facebookAuthService.signInWithFacebook();
    } catch (e) {
      _showSnackBarMessage('Unexpected error'.tr());
      return;
    }

    if (errorMessage == null) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (mounted && firebaseUser != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CompleteFamiliarRegistration(firebaseUser: firebaseUser)));
      }
    } else {
      _showSnackBarMessage(errorMessage);
    }
  }

  void _focusScope() {
    FocusScope.of(context).requestFocus(FocusNode());
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _emailNavigator() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TwoStepVerificationScreen(
                  identifier: _emailOrPhoneController.text.trim().toLowerCase(),
                  isSmsVerification: false,
                  firstName: _firstNameController.text.trim(),
                  lastNamePaternal: _lastNamePaternalController.text.trim(),
                  lastNameMaternal: _lastNameMaternalController.text.trim(),
                  email: _emailOrPhoneController.text.trim().toLowerCase(),
                  password: _passwordController.text,
                  userType: 'regular',
                  isStaff: false,
                  purpose: 'registration',
                )));
  }

  void _phoneNavigator() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TwoStepVerificationScreen(
                  identifier: _completePhoneNumber,
                  isSmsVerification: true,
                  phoneNumber: _completePhoneNumber,
                  purpose: "registration",
                  firstName: _firstNameController.text.trim(),
                  lastNamePaternal: _lastNamePaternalController.text.trim(),
                  lastNameMaternal: _lastNameMaternalController.text.trim(),
                  password: _passwordController.text,
                  userType: 'regular',
                  isStaff: false,
                )));
  }
}
