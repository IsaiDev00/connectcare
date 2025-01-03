import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/presentation/screens/general/auth/forgot_password/change_password.dart';
import 'package:connectcare/presentation/screens/general/auth/verification/two_step_verification_screen.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectcare/data/services/shared_preferences_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();
  bool _isLoading = true;
  // ignore: unused_field

  String userName = '';
  String userEmail = '';
  String userPhone = '';
  String userPassword = '';
  String userApellidoPaterno = '';
  String userApellidoMaterno = '';
  String userTipo = '';
  String? userId;
  String authProvider = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<bool> checkEmailExists(String email) async {
    var url = Uri.parse('$baseUrl/auth/email/$email');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> checkPhoneExists(String phone) async {
    var url = Uri.parse('$baseUrl/auth/telefono/$phone');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<void> _loadUserData() async {
    try {
      userId = await _sharedPreferencesService.getUserId();
      if (userId != null) {
        final url = Uri.parse('$baseUrl/auth/user_by_id/$userId');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body);

          setState(() {
            userName = userData['nombre'] ?? '';
            userEmail = userData['correo_electronico'] ?? '';
            userPhone = userData['telefono'] ?? '';
            userPassword = userData['contrasena'] ?? '';
            userApellidoPaterno = userData['apellido_paterno'] ?? '';
            userApellidoMaterno = userData['apellido_materno'] ?? '';
            userTipo = userData['tipo'] ?? '';
            authProvider = userData['auth_provider'] ?? '';
          });
        } else {
          throw Exception('User information could not be loaded.'.tr());
        }
      }
    } catch (e) {
      _userErrorResponse();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Edit profile'.tr()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 16.0),
                  _buildEditableCard(
                      'name'.tr(),
                      "$userName $userApellidoPaterno $userApellidoMaterno",
                      false),
                  _buildEditableCard('phone'.tr(), userPhone, true),
                  _buildEditableCard('email'.tr(), userEmail, true),
                  _buildEditableCard('password'.tr(), userPassword, true),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            "$userName $userApellidoPaterno $userApellidoMaterno",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8.0),
          Text(
            userTipo.isNotEmpty ? userTipo : "Type not available".tr(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCard(String label, String value, bool isEditable) {
    final bool canEditEmail =
        !(authProvider == 'google.com' || authProvider == 'facebook.com');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          label == 'password'.tr() ? '********' : value,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: isEditable
            ? IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () {
                  if (label == 'phone'.tr() || label == 'email'.tr()) {
                    _showEditFieldDialog(context, label, value);
                  } else if (label == 'password'.tr() && value.isEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePassword(
                          purpose: 'set',
                          userId: userEmail,
                        ),
                      ),
                    );
                  } else if (label == 'password'.tr()) {
                    _showPasswordVerificationDialog();
                  }
                },
              )
            : null,
      ),
    );
  }

  void _showEditFieldDialog(BuildContext context, String label, String value) {
    String countryCode = '+52';
    String phoneNumber = value;

    if (label == 'phone'.tr() && value.startsWith('+')) {
      value = value.substring(1);
      countryCode = '+${value.substring(0, 2)}';
      phoneNumber = value.substring(value.length - 10);
    }

    final TextEditingController controller =
        TextEditingController(text: phoneNumber);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('edit_label'.tr(args: [label])),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label == 'phone'.tr())
                Row(
                  children: [
                    CountryCodePicker(
                      initialSelection: 'MX',
                      favorite: ['52', 'MX'],
                      onChanged: (country) {
                        countryCode = country.dialCode ?? '+52';
                      },
                      dialogBackgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Phone Number'.tr(),
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                )
              else
                TextField(
                  controller: controller,
                  keyboardType: label == 'email'.tr()
                      ? TextInputType.emailAddress
                      : TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Enter new'.tr(args: [label]),
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'.tr()),
            ),
            TextButton(
              onPressed: () async {
                String input = controller.text.trim();

                if (input.isEmpty) {
                  Navigator.of(context).pop();
                  showCustomSnackBar(context, 'empty label'.tr(args: [label]));
                  return;
                }

                if (label == 'phone') {
                  if (!RegExp(r'^\d{10}$').hasMatch(input)) {
                    Navigator.of(context).pop();
                    showCustomSnackBar(context,
                        'Please enter a valid 10-digit phone number.'.tr());
                    return;
                  }

                  String formattedPhone = '$countryCode$input';

                  bool phoneExists = await checkPhoneExists(formattedPhone);
                  if (phoneExists) {
                    _phoneInUse();
                    return;
                  }
                  _navigateWithPhone(formattedPhone);
                } else if (label == 'email'.tr()) {
                  input = input.toLowerCase();

                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(input)) {
                    Navigator.of(context).pop();
                    showCustomSnackBar(
                        context, 'Please enter a valid email address.'.tr());
                    return;
                  }

                  bool emailExists = await checkEmailExists(input);
                  if (emailExists) {
                    _emailInUse();

                    return;
                  }

                  _navigateWithEmail(input);
                }
              },
              child: Text('Confirm'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordVerificationDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('First verify your current password'.tr()),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Enter current password'.tr(),
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'.tr()),
            ),
            TextButton(
              onPressed: () async {
                String passwordInput = controller.text.trim();

                if (passwordInput.isEmpty) {
                  Navigator.of(dialogContext).pop();
                  showCustomSnackBar(
                      dialogContext, 'Please enter your password'.tr());
                  return;
                }

                Navigator.of(dialogContext).pop();

                bool isPasswordCorrect = await _verifyPassword(passwordInput);

                if (!mounted) {
                  return;
                }

                if (isPasswordCorrect) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangePassword(
                        purpose: 'change',
                        userId: userId!,
                        isStaff: userTipo != 'regular' && userTipo != 'main',
                      ),
                    ),
                  );
                } else {
                  showCustomSnackBar(context, 'Incorrect password.'.tr());
                }
              },
              child: Text('Verify'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _userErrorResponse() {
    showCustomSnackBar(context, 'Error loading user data'.tr());
  }

  void _emailInUse() {
    Navigator.of(context).pop();
    showCustomSnackBar(context, 'This email address is already in use.'.tr());
  }

  void _navigateWithEmail(input) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TwoStepVerificationScreen(
          identifier: input,
          purpose: 'editData',
          isSmsVerification: false,
          userType: userTipo,
          userId: userId,
        ),
      ),
    );
  }

  void _navigateWithPhone(String formattedPhone) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TwoStepVerificationScreen(
          identifier: formattedPhone,
          purpose: 'editData',
          isSmsVerification: true,
          userType: userTipo,
        ),
      ),
    );
  }

  void _phoneInUse() {
    Navigator.of(context).pop();
    showCustomSnackBar(context, 'This phone number is already in use.'.tr());
  }

  Future<bool> _verifyPassword(String passwordInput) async {
    try {
      String tipo;
      if (userTipo == 'doctor' ||
          userTipo == 'nurse' ||
          userTipo == 'stretcher bearer' ||
          userTipo == 'human resources' ||
          userTipo == 'social worker' ||
          userTipo == 'administrator') {
        tipo = 'personal';
      } else {
        tipo = 'familiar';
      }
      final url = Uri.parse('$baseUrl/auth/verify-password');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'password': passwordInput,
          'userType': tipo,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['isValid'];
      } else {
        if (mounted) {
          showCustomSnackBar(context, 'Error verifying password.'.tr());
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, 'Error verifying password.'.tr());
      }
      return false;
    }
  }
}
