import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int? _resendToken;
  String? _verificationId;
  String? get currentVerificationId => _verificationId;

  int? get resendToken => _resendToken;

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onVerificationFailed,
    int? forceResendingToken,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(minutes: 2),
        forceResendingToken: forceResendingToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
          } catch (e) {
            onVerificationFailed('Automatic verification failed: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage;
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'The provided phone number is not valid.';
          } else if (e.code == 'quota-exceeded') {
            errorMessage = 'SMS quota for the project has been exceeded.';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many requests. Please try again later.';
          } else {
            errorMessage = e.message ?? "Verification failed.";
          }
          onVerificationFailed(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      onVerificationFailed('Error during phone number verification: $e');
    }
  }
}
