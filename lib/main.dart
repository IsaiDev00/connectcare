import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Import para notificaciones locales
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

// Screens y services
import 'package:connectcare/presentation/screens/general/dynamic_wrapper.dart';
import 'package:connectcare/data/services/navigation_service.dart';
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
import 'package:connectcare/presentation/screens/admin/hospital_reg/register_hospital_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/submit_clues_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/verification_code_screen.dart';
import 'package:connectcare/presentation/screens/admin/principal/profile_screen.dart';
import 'package:permission_handler/permission_handler.dart';

// Instancia global de FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Arrancamos la app
Future<void> main() async {
  // 1. Inicializa bindings de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa EasyLocalization
  await EasyLocalization.ensureInitialized();

  // 3. Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 4. FirebaseAppCheck
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  // 5. Inicializamos local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // 6. Pedir permisos de notificación (para iOS / Android 13+)
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    sound: true,
    badge: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  // 7. Escuchar notificaciones en Foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Notificación en Foreground: '
        '${message.notification?.title}, ${message.notification?.body}');

    final String notiTitle = message.notification?.title ?? 'Sin título';
    final String notiBody = message.notification?.body ?? 'Sin contenido';

    // Configuramos el canal de notificación (Android)
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'canal_critico', // ID único del canal
      'Notificaciones Críticas', // Nombre del canal
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Mostramos la notificación local
    await flutterLocalNotificationsPlugin.show(
      0,
      notiTitle,
      notiBody,
      platformChannelSpecifics,
    );
  });

  // 8. Pedir permisos de almacenamiento
  await solicitarPermisosAlmacenamiento();

  // 10. Lanzamos la app con EasyLocalization
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('es')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(initialRoute: '/'),
    ),
  );
}

Future<void> solicitarPermisosAlmacenamiento() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      final status = await Permission.photos.status;
      if (status.isGranted) {
        debugPrint('Permiso de IMÁGENES ya estaba concedido (Android 13+).');
        return;
      }
      if (status.isDenied) {
        final newStatus = await Permission.photos.request();
        if (newStatus.isGranted) {
          debugPrint('Permiso de IMÁGENES concedido (Android 13+).');
          return;
        } else if (newStatus.isPermanentlyDenied) {
          debugPrint('Permiso permanentemente denegado (Android 13+).');
          openAppSettings();
        } else {
          debugPrint('Permiso denegado (Android 13+).');
        }
      }
      if (status.isPermanentlyDenied) {
        debugPrint('Permiso permanentemente denegado (Android 13+).');
        openAppSettings();
      }
    } else {
      final status = await Permission.storage.status;
      if (status.isGranted) {
        debugPrint(
            'Permiso de almacenamiento ya estaba concedido (<= Android 12).');
        return;
      }
      if (status.isDenied) {
        final newStatus = await Permission.storage.request();
        if (newStatus.isGranted) {
          debugPrint('Permiso de almacenamiento concedido (<= Android 12).');
          return;
        } else if (newStatus.isPermanentlyDenied) {
          debugPrint('Permiso permanentemente denegado (<= Android 12).');
          openAppSettings();
        } else {
          debugPrint('Permiso denegado (<= Android 12).');
        }
      }
      if (status.isPermanentlyDenied) {
        debugPrint('Permiso permanentemente denegado (<= Android 12).');
        openAppSettings();
      }
    }
  } else {
    debugPrint(
        'Plataforma no es Android; no se solicitan permisos de almacenamiento.');
  }
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
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const DynamicWrapper(),
        '/mainScreen': (context) => MainScreen(),
        '/profile': (context) => ProfileScreen(),
        '/registerHospital': (context) => RegisterHospitalScreen(),
        '/submitCluesScreen': (context) => SubmitCluesScreen(),
        '/cluesErrScreen': (context) => CluesErrScreen(),
        '/verificationCodeScreen': (context) => VerificationCodeScreen(),
        '/manageRoomScreen': (context) => ManageRoomScreen(),
        '/manageProcedureScreen': (context) => ManageProcedureScreen(),
        '/manageServiceScreen': (context) => ManageServiceScreen(),
        '/hospitalFeaturesScreen': (context) => HospitalFeaturesScreen(),
        '/createRoomScreen': (context) => CreateRoomScreen(),
        '/createProcedureScreen': (context) => CreateProcedureScreen(),
        '/pacientReg': (context) => PatientRegScreen(),
        '/createServiceScreen': (context) => CreateServiceScreen(),
        '/adminStartScreen': (context) => AdminStartScreen(),
        '/addFloorsScreen': (context) => AddFloorsScreen(),
        '/shortTutorialScreen': (context) => ShortTutorialScreen(),
      },
    );
  }
}
