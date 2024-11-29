import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static final SharedPreferencesService _instance =
      SharedPreferencesService._internal();

  factory SharedPreferencesService() {
    return _instance;
  }

  SharedPreferencesService._internal();

  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

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

  Future<void> saveIsAdmin(bool isAdmin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAdmin', isAdmin);
  }

  Future<bool> getIsAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAdmin') ?? false;
  }

  Future<void> saveClues(String clues) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('clues', clues);
  }

  Future<String?> getClues() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('clues');
  }
}
