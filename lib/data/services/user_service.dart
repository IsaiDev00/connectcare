import 'package:connectcare/data/services/shared_preferences_service.dart';

class UserService {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  Future<Map<String, String?>> loadUserData() async {
    final userId = await _sharedPreferencesService.getUserId();
    final userType = await _sharedPreferencesService.getUserType();
    final clues = await _sharedPreferencesService.getClues();
    final patients = await _sharedPreferencesService.getPatients();

    return {
      'userId': userId,
      'userType': userType,
      'clues': clues?.isEmpty ?? true ? null : clues,
      'hasPatients': patients?.isEmpty ?? true ? null : patients,
    };
  }

  Future<void> saveUserSession(String userId, String userType,
      {String? clues, String? patients}) async {
    await _sharedPreferencesService.saveUserId(userId);
    await _sharedPreferencesService.saveUserType(userType);
    if (clues != null) {
      await _sharedPreferencesService.saveClues(clues);
    }
    if (patients != null) {
      await _sharedPreferencesService.savePatients(patients);
    }
  }

  Future<void> clearUserSession() async {
    await _sharedPreferencesService.clearUserId();
    await _sharedPreferencesService.clearUserType();
    await _sharedPreferencesService.clearClues();
    await _sharedPreferencesService.clearPatients();
  }
}
