import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, String?>> loadUserData() async {
    final User? firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      final userId = firebaseUser.uid;
      final userType = await _sharedPreferencesService.getUserType();

      return {
        'userId': userId,
        'userType': userType,
      };
    } else {
      return {
        'userId': null,
        'userType': null,
      };
    }
  }

  Future<void> saveUserSession(String userId, String userType) async {
    await _sharedPreferencesService.saveUserId(userId);
    await _sharedPreferencesService.saveUserType(userType);
  }

  Future<void> clearUserSession() async {
    await _sharedPreferencesService.clearUserId();
    await _sharedPreferencesService.clearUserType();
  }
}
