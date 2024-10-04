import 'package:connectcare/presentation/screens/auth/login_screen.dart'; //Importar la pantalla de login
import 'package:connectcare/presentation/screens/auth/password_recovery.dart';
import 'package:connectcare/presentation/screens/auth/verification_code.dart';
import 'package:flutter/material.dart';
import 'presentation/screens/auth/choose_role_screen.dart'; // Importar la pantalla de selección de rol
import 'presentation/screens/auth/hospital_staff_registration.dart'; // Importar la pantalla de registro del personal hospitalario
import 'presentation/screens/auth/family_registration.dart'; // Importar la pantalla de registro de familiares
import 'core/theme/app_theme.dart'; // Importar el tema
import 'presentation/screens/settings/terms_and_conditions_screen.dart'; // Ruta de términos de uso
import 'presentation/screens/settings/privacy_policy_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConnectCare',
      theme: AppTheme.lightTheme(), // Tema claro
      darkTheme: AppTheme.darkTheme(), // Tema oscuro
      themeMode:
          ThemeMode.system, // Cambia según la configuración del dispositivo
      initialRoute: '/', // Ruta inicial
      routes: {
        '/': (context) => ChooseRoleScreen(),
        '/hospitalStaffRegistration': (context) =>
            HospitalStaffRegistration(), // Ruta para el registro del personal hospitalario
        '/familyRegistration': (context) => FamilyRegistration(),
        '/termsAndConditions': (context) =>
            TermsAndConditionsScreen(), // Ruta para términos de uso
        '/privacyPolicy': (context) =>
            PrivacyPolicyScreen(), // Ruta para el registro de familiares
        '/loginScreen': (context) => LoginScreen(), 
        '/forgotPassword': (context) => PasswordRecovery(), 
        '/verificationCode': (context) => VerificationCode(), 
      },
    );
  }
}
