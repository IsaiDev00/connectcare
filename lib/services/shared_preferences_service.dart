import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static final SharedPreferencesService _instance =
      SharedPreferencesService._internal();

  factory SharedPreferencesService() {
    return _instance;
  }

  SharedPreferencesService._internal();

  // Guardar el ID del usuario
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  // Obtener el ID del usuario
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Limpiar el ID del usuario
  Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  // Guardar el código CLUES del usuario
  Future<void> saveCluesCode(String cluesCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cluesCode', cluesCode);
  }

  // Obtener el código CLUES del usuario
  Future<String?> getCluesCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('cluesCode');
  }

  // Guardar el código CLUES del usuario
  Future<void> saveVerificationCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('code', code);
  }

  // Obtener el código CLUES del usuario
  Future<String?> getVerificationCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('code');
  }

}
