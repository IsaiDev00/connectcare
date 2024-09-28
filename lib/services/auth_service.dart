class AuthService {
  Future<bool> login(String email, String password) async {
    // Aquí iría la lógica para autenticar al usuario, por ejemplo, con Firebase
    // Simulamos un login exitoso
    await Future.delayed(const Duration(seconds: 2));
    return email == 'test@example.com' && password == 'password';
  }
}
