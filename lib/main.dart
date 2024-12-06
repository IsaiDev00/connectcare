import 'package:connectcare/data/services/user_service.dart';
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
import 'package:connectcare/presentation/screens/family/patient_link_screen.dart';
import 'package:connectcare/presentation/screens/general/auth/forgot_password/change_password.dart';
import 'package:connectcare/presentation/screens/general/auth/forgot_password/forgot_password.dart';
import 'package:connectcare/presentation/screens/general/auth/login/login_screen.dart';
import 'package:connectcare/presentation/screens/doctor/doctor_home_screen.dart';
import 'package:connectcare/presentation/screens/doctor/documents.dart/patient_reg_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/clues_err_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/enter_hospital_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/hospital_name_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/register_hospital_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/submit_clues_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/verification_code_screen.dart';
import 'package:connectcare/presentation/screens/general/auth/verification/two_step_verification_screen.dart';
import 'package:connectcare/presentation/screens/general/dynamic_wrapper.dart';
import 'package:connectcare/presentation/screens/general/settings/about_us_screen.dart';
import 'package:connectcare/presentation/screens/general/settings/feedback_screen.dart';
import 'package:connectcare/presentation/screens/general/settings/languaje_screen.dart';
import 'package:connectcare/presentation/screens/general/settings/tutorial_screen.dart';
import 'package:connectcare/presentation/screens/human_resources/human_resources_home_screen.dart';
import 'package:connectcare/presentation/screens/family/main_family/main_family_member_home_screen.dart';
import 'package:connectcare/presentation/screens/nurse/nurse_home_screen.dart';
import 'package:connectcare/presentation/screens/admin/principal/profile_screen.dart';
import 'package:connectcare/presentation/screens/family/regular_family/regular_family_member_home_screen.dart';
import 'package:connectcare/presentation/screens/social_worker/social_worker_home_screen.dart';
import 'package:connectcare/presentation/screens/general/main_screen_staff.dart';
import 'package:connectcare/presentation/screens/general/settings/edit_profile_screen.dart';
import 'package:connectcare/presentation/screens/general/settings/settings_screen.dart';
import 'package:connectcare/presentation/screens/stretcher_bearer/stretcher_bearer_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'presentation/screens/general/auth/register/choose_role_screen.dart';
import 'presentation/screens/general/auth/register/staff_registration.dart';
import 'presentation/screens/general/auth/register/familiar_registration.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/general/settings/terms_and_conditions_screen.dart';
import 'presentation/screens/general/settings/privacy_policy_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectcare/presentation/screens/doctor/documents.dart/hoja_enfermeria_screen.dart';
import 'firebase_options.dart';
import 'package:connectcare/data/services/navigation_service.dart';
import 'package:connectcare/presentation/screens/general/auth/register/complete_staff_registration.dart';
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

  final userService = UserService();
  final userData = await userService.loadUserData();

  final initialRoute = _determineInitialRoute(userData);

  runApp(MyApp(initialRoute: initialRoute));
}

String _determineInitialRoute(Map<String, String?> userData) {
  final userId = userData['userId'];

  if (userId == null) {
    return '/';
  }

  return '/dynamicWrapper';
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
      initialRoute: initialRoute,
      routes: {
        '/': (context) => ChooseRoleScreen(),
        '/dynamicWrapper': (context) => const DynamicWrapper(),
        '/staffRegistration': (context) => StaffRegistration(),
        '/mainScreen': (context) => MainScreen(),
        '/familiarRegistration': (context) => FamiliarRegistration(),
        '/termsAndConditions': (context) => TermsAndConditionsScreen(),
        '/privacyPolicy': (context) => PrivacyPolicyScreen(),
        '/loginScreen': (context) => LoginScreen(),
        '/profile': (context) => ProfileScreen(),
        '/settings': (context) => SettingsScreen(),
        '/registerHospital': (context) => RegisterHospitalScreen(),
        '/enterHospital': (context) => EnterHospitalScreen(),
        '/mainScreenStaff': (context) => MainScreenStaff(),
        '/editProfileScreen': (context) => EditProfileScreen(),
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
        '/completeStaffRegistration': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments;
          if (arguments is User) {
            return CompleteStaffRegistration(firebaseUser: arguments);
          } else {
            return Scaffold(
              body: Center(
                child: Text('No user data available.'),
              ),
            );
          }
        },
        '/createServiceScreen': (context) => CreateServiceScreen(),
        '/adminStartScreen': (context) => AdminStartScreen(),
        '/addFloorsScreen': (context) => AddFloorsScreen(),
        '/shortTutorialScreen': (context) => ShortTutorialScreen(),
        '/doctorHomeScreen': (context) => const DoctorHomeScreen(),
        '/nurseHomeScreen': (context) => const NurseHomeScreen(),
        '/socialWorkerHomeScreen': (context) => const SocialWorkerHomeScreen(),
        '/stretcherBearerHomeScreen': (context) =>
            const StretcherBearerHomeScreen(),
        '/humanResourcesHomeScreen': (context) =>
            const HumanResourcesHomeScreen(),
        '/regularFamilyMemberHomeScreen': (context) =>
            const RegularFamilyMemberHomeScreen(),
        '/mainFamiliMemberHomeScreen': (context) =>
            const MainFamilyMemberHomeScreen(),
        '/forgotPassword': (context) => const ForgotPassword(),
        '/changePassword': (context) => const ChangePassword(),
        '/patientLink': (context) => const PatientLinkScreen(),
        '/twoStepVerification': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;

          return TwoStepVerificationScreen(
            identifier: args['identifier'],
            purpose: args['purpose'],
            idPersonal: args['idPersonal'],
            firstName: args['firstName'],
            lastNamePaternal: args['lastNamePaternal'],
            lastNameMaternal: args['lastNameMaternal'],
            userType: args['userType'],
            phoneNumber: args['phoneNumber'],
            email: args['email'],
            password: args['password'],
            isStaff: args['isStaff'] ?? false,
            isSmsVerification: args['isSmsVerification'] ?? false,
          );
        },
        '/feedback': (context) => const FeedbackScreen(),
        '/aboutUs': (context) => const AboutUsScreen(),
        '/tutorial': (context) => const TutorialScreen(),
        '/language': (context) => const LanguageScreen(),
      },
    );
  }
}
