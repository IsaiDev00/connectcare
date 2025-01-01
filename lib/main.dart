import 'package:connectcare/presentation/screens/admin/add_floors_screen.dart';
import 'package:connectcare/presentation/screens/admin/admin_start_screen.dart';
import 'package:connectcare/presentation/screens/admin/create_procedure_screen.dart';
import 'package:connectcare/presentation/screens/admin/create_room_screen.dart';
import 'package:connectcare/presentation/screens/admin/create_service_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_features_screen.dart';
import 'package:connectcare/presentation/screens/admin/manage_procedure_screen.dart';
import 'package:connectcare/presentation/screens/admin/manage_room_screen.dart';
import 'package:connectcare/presentation/screens/admin/manage_service_screen.dart';
import 'package:connectcare/presentation/screens/admin/principal/main_screen.dart';
import 'package:connectcare/presentation/screens/admin/short_tutorial_screen.dart';
import 'package:connectcare/presentation/screens/doctor/documents.dart/patient_reg_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/clues_err_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/hospital_name_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/register_hospital_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/submit_clues_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/verification_code_screen.dart';
import 'package:connectcare/presentation/screens/general/dynamic_wrapper.dart';
import 'package:connectcare/presentation/screens/admin/principal/profile_screen.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectcare/presentation/screens/doctor/documents.dart/hoja_enfermeria_screen.dart';
import 'firebase_options.dart';
import 'package:connectcare/data/services/navigation_service.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('es')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(initialRoute: '/'),
    ),
  );
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
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      navigatorKey: nav.navigatorKey,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const DynamicWrapper(),
        '/mainScreen': (context) => MainScreen(),
        '/profile': (context) => ProfileScreen(),
        '/registerHospital': (context) => RegisterHospitalScreen(),
        '/submitCluesScreen': (context) => SubmitCluesScreen(),
        '/cluesErrScreen': (context) => CluesErrScreen(),
        '/verificationCodeScreen': (context) => VerificationCodeScreen(),
        '/hospitalNameScreen': (context) => HospitalNameScreen(),
        '/manageRoomScreen': (context) => ManageRoomScreen(),
        '/manageProcedureScreen': (context) => ManageProcedureScreen(),
        '/manageServiceScreen': (context) => ManageServiceScreen(),
        '/hospitalFeaturesScreen': (context) => HospitalFeaturesScreen(),
        '/createRoomScreen': (context) => CreateRoomScreen(),
        '/createProcedureScreen': (context) => CreateProcedureScreen(),
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
