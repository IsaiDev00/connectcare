import 'dart:convert';
import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/presentation/screens/general/auth/login/login_screen.dart';
import 'package:connectcare/presentation/screens/general/auth/register/choose_role_screen.dart';
import 'package:connectcare/presentation/screens/general/settings/edit_profile_screen.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:http/http.dart' as http;
import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class ChangePassword extends StatefulWidget {
  final bool isStaff;
  final String? userId;
  final String purpose;
  const ChangePassword(
      {this.isStaff = false,
      required this.purpose,
      required this.userId,
      super.key});

  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final userService = UserService();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    String title = '';
    if (widget.purpose == "set") {
      title = 'Add a password'.tr();
    } else {
      title = 'Change your password'.tr();
    }

    var brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
                      try {
                        final String url;
                        Map<String, dynamic> body;

                        if (widget.purpose == 'set') {
                          url = '$baseUrl/auth/set-password';
                          body = {
                            'email': widget.userId,
                            'contrasena': _passwordController.text,
                          };
                        } else if (widget.isStaff) {
                          url =
                              '$baseUrl/personal/update-password/${widget.userId}';
                          body = {'contrasena': _passwordController.text};
                        } else {
                          url =
                              '$baseUrl/familiar/update-password/${widget.userId}';
                          body = {'contrasena': _passwordController.text};
                        }

                        final response = widget.purpose == 'set'
                            ? await http.post(
                                Uri.parse(url),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode(body),
                              )
                            : await http.put(
                                Uri.parse(url),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode(body),
                              );

                        if (response.statusCode == 200) {
                          _passwordUpdatedSuccesfully();
                          _navigator();
                        } else {
                          throw Exception('Error: ${response.body}');
                        }
                      } catch (e) {
                        _failedToChangePassword();
                      }
                    }
                  },
                  child: Text('Continue'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _passwordUpdatedSuccesfully() {
    showCustomSnackBar(context, 'Password updated successfully'.tr());
  }

  void _failedToChangePassword() {
    showCustomSnackBar(context, 'Failed to change password'.tr());
  }

  void _navigator() {
    if (widget.purpose == 'change') {
      Navigator.popUntil(context, (route) {
        return route is MaterialPageRoute &&
            route.builder(context) is EditProfileScreen;
      });
    } else if (widget.purpose == 'recover') {
      Navigator.popUntil(context, (route) {
        return route is MaterialPageRoute &&
            route.builder(context) is LoginScreen;
      });
    } else if (widget.purpose == 'set') {
      userService.clearUserSession();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ChooseRoleScreen()),
          (route) => false);
    }
  }
}
