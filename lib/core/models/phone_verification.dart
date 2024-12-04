class PhoneVerification {
  final String phoneNumber;
  final String verificationId;
  final bool isStaff;
  final String purpose;
  final Map<String, dynamic> userData;
  final String firstName;
  final String lastNamePaternal;
  final String lastNameMaternal;
  final String password;
  final String userType;
  final String idPersonal;

  PhoneVerification({
    required this.phoneNumber,
    required this.verificationId,
    required this.isStaff,
    required this.purpose,
    required this.userData,
    required this.firstName,
    required this.lastNamePaternal,
    required this.lastNameMaternal,
    required this.password,
    required this.userType,
    required this.idPersonal,
  });

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'verificationId': verificationId,
      'isStaff': isStaff,
      'purpose': purpose,
      'userData': userData,
      'firstName': firstName,
      'lastNamePaternal': lastNamePaternal,
      'lastNameMaternal': lastNameMaternal,
      'password': password,
      'userType': userType,
      'idPersonal': idPersonal,
    };
  }
}
