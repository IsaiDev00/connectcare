import 'package:connectcare/data/services/shared_preferences_service.dart';

class UserService {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

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

  Future<void> clearUserSession() async {
    await _sharedPreferencesService.clearUserId();
    await _sharedPreferencesService.clearUserType();
    await _sharedPreferencesService.clearClues();
    await _sharedPreferencesService.clearPatients();
    await _sharedPreferencesService.clearStatus();
    await _sharedPreferencesService.clearSchedule();
    await _sharedPreferencesService.clearServices();
  }
}
