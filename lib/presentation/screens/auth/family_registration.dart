import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FamilyRegistration extends StatefulWidget {
  const FamilyRegistration({super.key});

  @override
  FamilyRegistrationState createState() => FamilyRegistrationState();
}

class FamilyRegistrationState extends State<FamilyRegistration> {
  final _formKey = GlobalKey<FormState>();

  bool isEmailMode =
      false; // Variable para controlar si estamos en modo email o phone

  // Controladores de texto para cada campo
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNamePaternalController =
      TextEditingController();
  final TextEditingController _lastNameMaternalController =
      TextEditingController();
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Función para validar si el email ya está en uso (RQNF4)
  Future<bool> _isEmailInUse(String email) async {
    // Aquí iría la lógica para verificar si el email está en uso
    // Por ahora, simulamos que el email "test@example.com" ya está en uso
    await Future.delayed(
        const Duration(seconds: 1)); // Simular una llamada a la API
    return email == 'test@example.com';
  }

  // Función para validar si el teléfono ya está en uso (RQNF5)
  Future<bool> _isPhoneInUse(String phone) async {
    // Aquí iría la lógica para verificar si el teléfono está en uso
    // Por ahora, simulamos que el teléfono "1234567890" ya está en uso
    await Future.delayed(
        const Duration(seconds: 1)); // Simular una llamada a la API
    return phone == '1234567890';
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register with ConnectCare'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:
              brightness == Brightness.dark ? Colors.transparent : Colors.white,
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: brightness == Brightness.dark
              ? Brightness.dark
              : Brightness.light,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Añadimos el GlobalKey al Form
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                // Campo para el nombre
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    // RQNF1: Validar que el campo no esté vacío
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Campo para el apellido paterno
                TextFormField(
                  controller: _lastNamePaternalController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name (Paternal)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    // RQNF1: Validar que el campo no esté vacío
                    if (value == null || value.isEmpty) {
                      return 'Please enter your paternal last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Campo para el apellido materno
                TextFormField(
                  controller: _lastNameMaternalController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name (Maternal)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    // RQNF1: Validar que el campo no esté vacío
                    if (value == null || value.isEmpty) {
                      return 'Please enter your maternal last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Campo dinámico para el número de teléfono o correo electrónico
                TextFormField(
                  controller: _emailOrPhoneController,
                  decoration: InputDecoration(
                    labelText: isEmailMode ? 'Email Address' : 'Phone Number',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: isEmailMode
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEmailMode
                          ? 'Please enter your email address'
                          : 'Please enter your phone number';
                    }
                    if (isEmailMode) {
                      // RQNF2: Validar formato de email
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                    } else {
                      // RQNF3: Validar número de teléfono de 10 dígitos numéricos
                      final phoneRegex = RegExp(r'^\d{10}$');
                      if (!phoneRegex.hasMatch(value)) {
                        return 'Please enter a valid 10-digit phone number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Campo para la contraseña
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    // RQNF1: Validar que el campo no esté vacío
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    // RQNF6: Validar que la contraseña cumpla con los requisitos
                    final passwordRegex = RegExp(
                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[¡@#\$%^&*~`+\-/<>,.]).{8,}$');
                    if (!passwordRegex.hasMatch(value)) {
                      return 'Password must be at least 8 characters and include uppercase, lowercase, numbers, and symbols';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Campo para confirmar la contraseña
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    // RQNF7: Validar que las contraseñas coincidan
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Botón para continuar
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Guardar una referencia al ScaffoldMessenger antes del await
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      // Validación de email o teléfono en uso
                      if (isEmailMode) {
                        // RQNF4: Validar que el email no esté en uso
                        bool emailInUse =
                            await _isEmailInUse(_emailOrPhoneController.text);
                        if (!mounted) {
                          return;
                        } // Verificar si el widget sigue montado
                        if (emailInUse) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('This email is already in use'),
                            ),
                          );
                          return;
                        }
                      } else {
                        // RQNF5: Validar que el teléfono no esté en uso
                        bool phoneInUse =
                            await _isPhoneInUse(_emailOrPhoneController.text);
                        if (!mounted) {
                          return;
                        } // Verificar si el widget sigue montado
                        if (phoneInUse) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content:
                                  Text('This phone number is already in use'),
                            ),
                          );
                          return;
                        }
                      }

                      // Si todas las validaciones pasan, proceder con el registro
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Registration successful'),
                        ),
                      );
                    }
                  },
                  child: const Text('Continue'),
                ),
                const SizedBox(height: 20),

                // Texto "or"
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("or"),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),

                // Botón dinámico para alternar entre Email y Teléfono
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isEmailMode =
                          !isEmailMode; // Alternar entre email y phone
                      _emailOrPhoneController
                          .clear(); // Limpiar el TextField al cambiar
                    });
                  },
                  icon: Icon(
                    isEmailMode ? Icons.phone : Icons.email_outlined,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  label: Text(
                    isEmailMode ? 'Continue with Phone' : 'Continue with Email',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 10),

                ElevatedButton.icon(
                  onPressed: () {
                    // Lógica para iniciar sesión con Facebook
                  },
                  icon: FaIcon(FontAwesomeIcons.facebook,
                      color: brightness == Brightness.dark
                          ? Colors.white
                          : Colors.blue),
                  label: Text(
                    'Continue with Facebook',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 10),

                ElevatedButton.icon(
                  onPressed: () {
                    // Lógica para iniciar sesión con Google
                  },
                  icon: FaIcon(FontAwesomeIcons.google,
                      color: brightness == Brightness.dark
                          ? Colors.white
                          : Colors.red),
                  label: Text(
                    'Continue with Google',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 10),

                ElevatedButton.icon(
                  onPressed: () {
                    // Lógica para iniciar sesión con Apple
                  },
                  icon: FaIcon(FontAwesomeIcons.apple,
                      color: Theme.of(context).iconTheme.color),
                  label: Text(
                    'Continue with Apple',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
