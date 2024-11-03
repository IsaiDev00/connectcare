import 'package:connectcare/presentation/screens/admin/add_floors_screen.dart';
import 'package:connectcare/presentation/screens/admin/admin_home_screen.dart';
import 'package:connectcare/presentation/screens/admin/admin_start_screen.dart';
import 'package:connectcare/presentation/screens/admin/create_medicament_screen.dart';
import 'package:connectcare/presentation/screens/admin/create_procedure_screen.dart';
import 'package:connectcare/presentation/screens/admin/create_room_screen.dart';
import 'package:connectcare/presentation/screens/admin/create_service_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_features_screen.dart';
import 'package:connectcare/presentation/screens/admin/manage_medicaments_screen.dart';
import 'package:connectcare/presentation/screens/admin/manage_procedure_screen.dart';
import 'package:connectcare/presentation/screens/admin/manage_room_screen.dart';
import 'package:connectcare/presentation/screens/admin/manage_service_screen.dart';
import 'package:connectcare/presentation/screens/admin/short_tutorial_screen.dart';
import 'package:connectcare/presentation/screens/auth/login_screen.dart';
import 'package:connectcare/presentation/screens/auth/password_recovery.dart';
import 'package:connectcare/presentation/screens/auth/verification_code.dart';
import 'package:connectcare/presentation/screens/hospital_reg/clues_err_screen.dart';
import 'package:connectcare/presentation/screens/hospital_reg/enter_hospital_screen.dart';
import 'package:connectcare/presentation/screens/hospital_reg/hospital_name_screen.dart';
import 'package:connectcare/presentation/screens/hospital_reg/register_hospital_screen.dart';
import 'package:connectcare/presentation/screens/hospital_reg/submit_clues_screen.dart';
import 'package:connectcare/presentation/screens/hospital_reg/verification_code_screen.dart';
import 'package:connectcare/presentation/screens/principal/profile_screen.dart';
import 'package:connectcare/presentation/screens/principal/wrapper.dart';
import 'package:connectcare/presentation/screens/principal/wrapper_admin.dart';
import 'package:connectcare/presentation/screens/settings/edit_profile_screen.dart';
import 'package:connectcare/presentation/screens/settings/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'presentation/screens/auth/choose_role_screen.dart';
import 'presentation/screens/auth/hospital_staff_registration.dart';
import 'presentation/screens/auth/family_registration.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/settings/terms_and_conditions_screen.dart';
import 'presentation/screens/settings/privacy_policy_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:connectcare/data/services/navigation_service.dart';
import 'package:connectcare/presentation/screens/auth/complete_staff_registration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final NavigationService nav = NavigationService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConnectCare',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      initialRoute: '/mainScreen',
      routes: {
        '/': (context) => ChooseRoleScreen(),
        '/hospitalStaffRegistration': (context) => HospitalStaffRegistration(),
        '/familyRegistration': (context) => FamilyRegistration(),
        '/termsAndConditions': (context) => TermsAndConditionsScreen(),
        '/privacyPolicy': (context) => PrivacyPolicyScreen(),
        '/loginScreen': (context) => LoginScreen(),
        '/forgotPassword': (context) => PasswordRecovery(),
        '/verificationCode': (context) => VerificationCode(),
        '/profile': (context) => ProfileScreen(),
        '/settings': (context) => SettingsScreen(),
        '/registerHospital': (context) => RegisterHospitalScreen(),
        '/enterHospital': (context) => EnterHospitalScreen(),
        '/mainScreen': (context) => Wrapper(index: 0),
        '/management': (context) => WrapperAdmin(index: 1),
        '/example': (context) => Wrapper(index: 2),
        '/example2': (context) => Wrapper(index: 3),
        '/editProfileScreen': (context) => EditProfileScreen(),
        '/submitCluesScreen': (context) => SubmitCluesScreen(),
        '/cluesErrScreen': (context) => CluesErrScreen(),
        '/verificationCodeScreen': (context) => VerificationCodeScreen(),
        '/hospitalNameScreen': (context) => HospitalNameScreen(),
        '/adminHomeScreen': (context) => WrapperAdmin(index: 0),
        '/manageRoomScreen': (context) => ManageRoomScreen(),
        '/manageProcedureScreen': (context) => ManageProcedureScreen(),
        '/manageServiceScreen': (context) => ManageServiceScreen(),
        '/manageMedications': (context) => ManageMedications(),
        '/hospitalFeaturesScreen': (context) => HospitalFeaturesScreen(),
        '/createRoomScreen': (context) => CreateRoomScreen(),
        '/createProcedureScreen': (context) => CreateProcedureScreen(),
        '/createMedicamentScreen': (context) => CreateMedicamentScreen(),
        'completeStaffRegistration': (context) {
          final firebaseUser =
              ModalRoute.of(context)!.settings.arguments as User;
          return CompleteStaffRegistration(firebaseUser: firebaseUser);
        },
        '/createServiceScreen': (context) => CreateServiceScreen(),
        '/adminStartScreen': (context) => AdminStartScreen(),
        '/addFloorsScreen': (context) => AddFloorsScreen(),
        '/shortTutorialScreen': (context) => ShortTutorialScreen(),
      },
    );
  }
}
