import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/presentation/screens/general/auth/register/choose_role_screen.dart';
import 'package:connectcare/presentation/screens/general/settings/about_us_screen.dart';
import 'package:connectcare/presentation/screens/general/settings/edit_profile_screen.dart';
import 'package:connectcare/presentation/screens/general/settings/feedback_screen.dart';
import 'package:connectcare/presentation/screens/general/settings/languaje_screen.dart';
import 'package:connectcare/presentation/screens/general/settings/tutorial_screen.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final userService = UserService();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var colorScheme = theme.colorScheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Ajustes"),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildSettingsCard(
                      context,
                      title: 'Cuenta',
                      titleColor: colorScheme.onSurface,
                      options: [
                        _buildOption(context,
                            icon: Icons.person,
                            text: 'Editar perfil',
                            iconColor: colorScheme.onSurface,
                            textColor: colorScheme.onSurface,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditProfileScreen()))),
                      ],
                    ),
                    _buildSettingsCard(
                      context,
                      title: 'Preferencias',
                      titleColor: colorScheme.onSurface,
                      options: [
                        _buildOption(context,
                            icon: Icons.language,
                            text: 'Idioma',
                            iconColor: colorScheme.onSurface,
                            textColor: colorScheme.onSurface,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LanguageScreen()))),
                        _buildOption(context,
                            icon: Icons.play_circle_outline,
                            text: 'Tutorial de uso',
                            iconColor: colorScheme.onSurface,
                            textColor: colorScheme.onSurface,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TutorialScreen()))),
                      ],
                    ),
                    _buildSettingsCard(
                      context,
                      title: 'Información',
                      titleColor: colorScheme.onSurface,
                      options: [
                        _buildOption(context,
                            icon: Icons.info_outline,
                            text: 'Sobre nosotros',
                            iconColor: colorScheme.onSurface,
                            textColor: colorScheme.onSurface,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AboutUsScreen()))),
                        _buildOption(context,
                            icon: Icons.feedback_outlined,
                            text: 'Quejas y sugerencias',
                            iconColor: colorScheme.onSurface,
                            textColor: colorScheme.onSurface,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FeedbackScreen()))),
                      ],
                    ),
                    _buildSettingsCard(
                      context,
                      title: 'Cuenta',
                      titleColor: colorScheme.onSurface,
                      options: [
                        _buildOption(
                          context,
                          icon: Icons.logout,
                          text: 'Cerrar sesión',
                          iconColor: Colors.red,
                          textColor: Colors.red,
                          onTap: () {
                            userService.clearUserSession();
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChooseRoleScreen()),
                                (route) => false);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context,
      {required String title,
      required List<Widget> options,
      required Color titleColor}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: Theme.of(context).cardColor, // Adapta al tema claro/oscuro
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: titleColor, // Usa el color dinámico del tema
                  ),
            ),
            const SizedBox(height: 10),
            ...options,
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
