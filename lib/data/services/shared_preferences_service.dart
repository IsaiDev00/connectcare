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

  Future<void> saveUserType(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', userType);
  }

  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType');
  }

  Future<void> clearUserType() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userType');
  }

  Future<void> savePatients(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('patients', userType);
  }

  Future<String?> getPatients() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('patients');
  }

  Future<void> clearPatients() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('patients');
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

  Future<void> clearClues() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('clues');
  }

  Future<void> saveStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('status', status);
  }

  Future<String?> getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('status');
  }

  Future<void> clearStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('status');
  }

  Future<void> saveSchedule(String schedule) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('schedule', schedule);
  }

  Future<String?> getSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('schedule');
  }

  Future<void> clearSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('schedule');
  }

  Future<void> saveServices(String services) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('services', services);
  }

  Future<String?> getServices() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('services');
  }

  Future<void> clearServices() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('services');
  }
}
