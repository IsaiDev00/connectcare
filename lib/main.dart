import 'package:connectcare/presentation/screens/admin/add_floors_screen.dart';
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
import 'package:connectcare/presentation/screens/admin/principal/main_screen.dart';
import 'package:connectcare/presentation/screens/admin/short_tutorial_screen.dart';
import 'package:connectcare/presentation/screens/admin/wrapper_admin.dart';
import 'package:connectcare/presentation/screens/doctor/documents.dart/patient_reg_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/clues_err_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/enter_hospital_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/hospital_name_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/register_hospital_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/submit_clues_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/verification_code_screen.dart';
import 'package:connectcare/presentation/screens/general/dynamic_wrapper.dart';
import 'package:connectcare/presentation/screens/admin/principal/profile_screen.dart';
import 'package:connectcare/presentation/screens/general/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectcare/presentation/screens/doctor/documents.dart/hoja_enfermeria_screen.dart';
import 'firebase_options.dart';
import 'package:connectcare/data/services/navigation_service.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  runApp(MyApp(initialRoute: '/'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({required this.initialRoute, super.key});
  static final NavigationService nav = NavigationService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ConnectCare',
      navigatorKey: nav.navigatorKey,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      initialRoute: '/pacientReg',
      routes: {
        '/': (context) => const DynamicWrapper(),
        '/mainScreen': (context) => MainScreen(),
        '/profile': (context) => ProfileScreen(),
        '/settings': (context) => SettingsScreen(),
        '/registerHospital': (context) => RegisterHospitalScreen(),
        '/enterHospital': (context) => EnterHospitalScreen(),
        '/submitCluesScreen': (context) => SubmitCluesScreen(),
        '/cluesErrScreen': (context) => CluesErrScreen(),
        '/verificationCodeScreen': (context) => VerificationCodeScreen(),
        '/hospitalNameScreen': (context) => HospitalNameScreen(),
        '/adminHomeScreen': (context) => WrapperAdmin(index: 0),
        '/management': (context) => WrapperAdmin(index: 1),
        '/manageRoomScreen': (context) => ManageRoomScreen(),
        '/manageProcedureScreen': (context) => ManageProcedureScreen(),
        '/manageServiceScreen': (context) => ManageServiceScreen(),
        '/manageMedications': (context) => ManageMedications(),
        '/hospitalFeaturesScreen': (context) => HospitalFeaturesScreen(),
        '/createRoomScreen': (context) => CreateRoomScreen(),
        '/createProcedureScreen': (context) => CreateProcedureScreen(),
        '/createMedicamentScreen': (context) => CreateMedicamentScreen(),
        '/pacientReg': (context) => PatientRegScreen(),
        '/hojaEnfermeriaScreen': (context) => HojaEnfermeriaScreen(),
        '/createServiceScreen': (context) => CreateServiceScreen(),
        '/adminStartScreen': (context) => AdminStartScreen(),
        '/addFloorsScreen': (context) => AddFloorsScreen(),
        '/shortTutorialScreen': (context) => ShortTutorialScreen(),
      },
    );
  }
}
