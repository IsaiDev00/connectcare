import 'package:connectcare/presentation/screens/general/auth/register/complete_staff_registration.dart';
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

class StaffRegistration extends StatefulWidget {
  const StaffRegistration({super.key});

  @override
  StaffRegistrationState createState() => StaffRegistrationState();
}

class StaffRegistrationState extends State<StaffRegistration> {
  final List<String> userTypes = [
    'Administrator',
    'Doctor',
    'Nurse',
    'Social worker',
    'Stretcher bearer',
    'Human resources'
  ];

  final _formKey = GlobalKey<FormState>();

  bool isEmailMode = false;
  String _completePhoneNumber = '';
  String _countryCode = "+52";
  // ignore: unused_field
  int? _resendToken;

  final TextEditingController _phoneNumberController = TextEditingController();
  String? _selectedUserType;
  final TextEditingController idController = TextEditingController();
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

  Future<bool> checkStaffIdExists(String staffId) async {
    final url = Uri.parse('$baseUrl/personal/id/$staffId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      return false;
    } else {
      throw Exception('Error verifying Staff ID: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register with ConnectCare'),
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
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'Staff ID',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your staff ID';
                    }
                    if (value.length != 8) {
                      return 'Staff ID must be exactly 8 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _lastNamePaternalController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name (Paternal)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your paternal last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _lastNameMaternalController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name (Maternal)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your maternal last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedUserType,
                  decoration: const InputDecoration(
                    labelText: 'User type',
                    border: OutlineInputBorder(),
                  ),
                  items: userTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(
                        type,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedUserType = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a user type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
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
                    errorMaxLines: 3,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    final passwordRegex = RegExp(
                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#%^&*~`+\-/<>,.]).{8,}$');
                    if (!passwordRegex.hasMatch(value)) {
                      return 'Password must be at least 8 characters and include uppercase, lowercase, numbers, and symbols ¡@#%^&*~`+-/<>,.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text ||
                        value == null ||
                        value.isEmpty) {
                      return 'Passwords do not match';
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
                        bool staffIdExists =
                            await checkStaffIdExists(idController.text);
                        if (staffIdExists) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                                content: Text('Staff ID is already in use')),
                          );
                          return;
                        }
                        bool emailExists = await checkEmailExists(
                            _emailOrPhoneController.text);
                        if (emailExists) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text('Email is already in use')),
                          );
                          return;
                        }
                        _emailNavigate();
                      } else {
                        _completePhoneNumber =
                            '$_countryCode${_phoneNumberController.text}';

                        bool staffIdExists =
                            await checkStaffIdExists(idController.text);
                        if (staffIdExists) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                                content: Text('Staff ID is already in use')),
                          );
                          return;
                        }
                        bool phoneExists =
                            await checkPhoneExists(_completePhoneNumber);
                        if (phoneExists) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                                content:
                                    Text('Phone number is already in use')),
                          );
                          return;
                        }
                        _phoneNavigate();
                      }
                    }
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
                    'Continue with Facebook',
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
                    'Continue with Google',
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
                    CompleteStaffRegistration(firebaseUser: firebaseUser)));
      } else {
        _showSnackBarMessage('Failed to retrieve Google user.');
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
      _showSnackBarMessage('Error inesperado: $e');
      return;
    }

    if (errorMessage == null) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (mounted && firebaseUser != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CompleteStaffRegistration(firebaseUser: firebaseUser)));
      }
    } else {
      _showSnackBarMessage(errorMessage);
    }
  }

  void _focusScope() {
    FocusScope.of(context).requestFocus(FocusNode());
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _emailNavigate() {
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
                  userType: _selectedUserType!.toLowerCase(),
                  userId: idController.text,
                  isStaff: true,
                  purpose: 'registration',
                )));
  }

  void _phoneNavigate() {
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
                  userType: _selectedUserType!.toLowerCase(),
                  userId: idController.text,
                  isStaff: true,
                )));
  }
}
