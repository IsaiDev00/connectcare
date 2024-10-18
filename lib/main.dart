import 'package:connectcare/presentation/screens/admin/admin_home_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_features_screen.dart';
import 'package:connectcare/presentation/screens/admin/manage_procedure_screen.dart';
import 'package:connectcare/presentation/screens/admin/manage_room_screen.dart';
import 'package:connectcare/presentation/screens/admin/manage_service_screen.dart';
import 'package:connectcare/presentation/screens/auth/login_screen.dart';
import 'package:connectcare/presentation/screens/auth/password_recovery.dart';
import 'package:connectcare/presentation/screens/auth/verification_code.dart';
import 'package:connectcare/presentation/screens/hospital_reg/clues_err_screen.dart';
import 'package:connectcare/presentation/screens/hospital_reg/enter_hospital_screen.dart';
import 'package:connectcare/presentation/screens/hospital_reg/hospital_name_screen.dart';
import 'package:connectcare/presentation/screens/hospital_reg/register_hospital_screen.dart';
import 'package:connectcare/presentation/screens/hospital_reg/submit_clues_screen.dart';
import 'package:connectcare/presentation/screens/hospital_reg/verification_code_screen.dart';
import 'package:connectcare/presentation/screens/principal/main_screen.dart';
import 'package:connectcare/presentation/screens/principal/profile_screen.dart';
import 'package:connectcare/presentation/screens/settings/edit_profile_screen.dart';
import 'package:connectcare/presentation/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'presentation/screens/auth/choose_role_screen.dart';
import 'presentation/screens/auth/hospital_staff_registration.dart';
import 'presentation/screens/auth/family_registration.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/settings/terms_and_conditions_screen.dart';
import 'presentation/screens/settings/privacy_policy_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
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
        '/profile': (context) => ProfileScreen(),
        '/settings': (context) => SettingsScreen(),
        '/registerHospital': (context) => RegisterHospitalScreen(),
        '/enterHospital': (context) => EnterHospitalScreen(),
        '/mainScreen': (context) => MainScreen(),
        '/editProfileScreen': (context) => EditProfileScreen(),
        '/submitCluesScreen': (context) => SubmitCluesScreen(),
        '/cluesErrScreen': (context) => CluesErrScreen(),
        '/verificationCodeScreen': (context) => VerificationCodeScreen(
              detectedText: '',
            ),
        '/hospitalNameScreen': (context) => HospitalNameScreen(
              detectedText: '',
            ),
        '/adminHomeScreen': (context) => AdminHomeScreen(),
        '/manageRoomScreen': (context) => ManageRoomScreen(),
        '/manageProcedureScreen': (context) => ManageProcedureScreen(),
        '/manageServiceScreen': (context) => ManageServiceScreen(),
        '/hospitalFeaturesScreen': (context) => HospitalFeaturesScreen(),
      },
    );
  }
}
