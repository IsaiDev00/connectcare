import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';

class UserService {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  /// Carga de datos de usuario desde SharedPreferences
  Future<Map<String, String?>> loadUserData() async {
    final userId = await _sharedPreferencesService.getUserId();
    final userType = await _sharedPreferencesService.getUserType();
    final clues = await _sharedPreferencesService.getClues();
    final patients = await _sharedPreferencesService.getPatients();
    final status = await _sharedPreferencesService.getStatus();
    final schedule = await _sharedPreferencesService.getSchedule();
    final services = await _sharedPreferencesService.getServices();

    return {
      'userId': userId,
      'userType': userType,
      'clues': clues?.isEmpty ?? true ? null : clues,
      'patients': patients?.isEmpty ?? true ? null : patients,
      'status': status?.isEmpty ?? true ? null : status,
      'schedule': schedule?.isEmpty ?? true ? null : schedule,
      'services': services?.isEmpty ?? true ? null : services,
    };
  }

  Future<void> saveUserSession(String userId,
      {String? userType,
      String? clues,
      String? patients,
      String? status,
      String? schedule,
      String? services}) async {
    await _sharedPreferencesService.saveUserId(userId);
    if (userType != null) {
      await _sharedPreferencesService.saveUserType(userType);
    }
    if (clues != null) {
      await _sharedPreferencesService.saveClues(clues);
    }
    if (patients != null) {
      await _sharedPreferencesService.savePatients(patients);
    }
    if (status != null) {
      await _sharedPreferencesService.saveStatus(status);
    }
    if (schedule != null) {
      await _sharedPreferencesService.saveSchedule(schedule);
    }
    if (services != null) {
      await _sharedPreferencesService.saveServices(services);
    }
  }

  /// Limpia la sesión del usuario (logout, etc.)
  Future<void> clearUserSession() async {
    await _sharedPreferencesService.clearUserId();
    await _sharedPreferencesService.clearUserType();
    await _sharedPreferencesService.clearClues();
    await _sharedPreferencesService.clearPatients();
    await _sharedPreferencesService.clearStatus();
    await _sharedPreferencesService.clearSchedule();
    await _sharedPreferencesService.clearServices();
  }

  /// Método para solicitar el token a FCM y actualizarlo en el servidor
  /// usando el userId y userType que tenemos en SharedPreferences.
  Future<void> updateFirebaseTokenAndSendNotification() async {
    try {
      // 1. Obtenemos el userId de SharedPreferences
      final userId = await _sharedPreferencesService.getUserId();

      // Si no hay userId, no hacemos nada.
      if (userId == null || userId.isEmpty) {
        print("No se puede enviar token porque userId es nulo o está vacío.");
        return;
      }

      // 2. Obtenemos el userType
      final userType = await _sharedPreferencesService.getUserType();

      // 3. Obtenemos el token de Firebase
      final String? token = await FirebaseMessaging.instance.getToken();

      if (token == null) {
        print("No se pudo obtener el token de FirebaseMessaging");
        return;
      }

      // 4. Actualizamos el token en la base de datos
      final responseUpdateToken = await http.post(
        Uri.parse('$baseUrl/firebase_notification/update-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
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

      // 5. Enviar una notificación de prueba
      String? titulo;
      String? cuerpo;

      switch (userType) {
        case 'doctor':
          titulo = "Doctor";
          cuerpo = "Acabas de iniciar sesión como doctor";
          break;
        case 'administrator':
          titulo = "Administrador";
          cuerpo = "Acabas de iniciar sesión como administrador";
          break;
        default:
          // Si no coincide con ninguno de los anteriores
          titulo = "Bienvenido/a";
          cuerpo = "Has iniciado sesión.";
      }

      final responseSendNotification = await http.post(
        Uri.parse('$baseUrl/firebase_notification/send-notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'title': titulo,
          'body': cuerpo,
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
      print("Error de conexión al actualizar token y/o enviar notificación: $error");
    }
  }
}
