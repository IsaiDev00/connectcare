import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

// Import para notificaciones locales
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
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
import 'package:connectcare/presentation/screens/admin/hospital_reg/hospital_name_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/register_hospital_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/submit_clues_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/verification_code_screen.dart';
import 'package:connectcare/presentation/screens/admin/principal/profile_screen.dart';
import 'package:connectcare/core/constants/constants.dart';

// Instancia global de FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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

  // Inicializamos local notifications (Android / iOS si deseas)
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  // Si quieres iOS, añade iOSInitializationSettings(...)
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  // Instancia de Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Obtenemos el token
  String? token = await messaging.getToken();
  print("TOKEN FIREBASE :D $token");

  // PEDIMOS PERMISOS (iOS + Android 13+)
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    sound: true,
    badge: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  // Escuchar cuando la notificación llega con la app en foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print(
        'Notificación en Foreground: ${message.notification?.title}, ${message.notification?.body}');

    // Preparar datos para la notificación local
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
      0, // ID de la notificación
      notiTitle,
      notiBody,
      platformChannelSpecifics,
    );
  });

  // Enviamos token al backend si no es nulo
  if (token != null) {
    await _sendTokenAndNotification(token);
  } else {
    print("Error: El token es nulo, no se puede enviar al backend");
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('es')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(initialRoute: '/'),
    ),
  );
}

// Función para llamar al backend
Future<void> _sendTokenAndNotification(String token) async {
  try {
    // 1. Actualizamos el token en la base de datos
    final responseUpdateToken = await http.post(
      Uri.parse('$baseUrl/firebase_notification/update-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': '99999991',
        'fcmToken': token,
      }),
    );

    if (responseUpdateToken.statusCode == 200) {
      print("Token actualizado correctamente en el servidor");
    } else {
      print(
        "Error al actualizar el token. Código: ${responseUpdateToken.statusCode}. "
        "Mensaje: ${responseUpdateToken.body}",
      );
    }
  } catch (error) {
    print("Error de conexión al enviar el token: $error");
  }

  try {
    // 2. Enviamos la notificación
    final responseSendNotification = await http.post(
      Uri.parse('$baseUrl/firebase_notification/send-notification'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': '99999991',
        'title': 'titulo ejemplo',
        'body': 'mensaje ejemplo',
      }),
    );

    if (responseSendNotification.statusCode == 200) {
      print("Notificación enviada correctamente");
    } else {
      print(
        "Error al enviar la notificación. Código: "
        "${responseSendNotification.statusCode}. "
        "Mensaje: ${responseSendNotification.body}",
      );
    }
  } catch (error) {
    print("Error de conexión al enviar la notificación: $error");
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
        '/hospitalNameScreen': (context) => HospitalNameScreen(),
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
