import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectcare/data/repositories/table/personal_repository.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:connectcare/services/shared_preferences_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectcare/presentation/screens/auth/complete_staff_registration.dart';

class HospitalStaffRegistration extends StatefulWidget {
  const HospitalStaffRegistration({super.key});

  @override
  HospitalStaffRegistrationState createState() =>
      HospitalStaffRegistrationState();
}

class HospitalStaffRegistrationState extends State<HospitalStaffRegistration> {
  final List<String> userTypes = [
    'Administrador',
    'Médico',
    'Enfermero',
    'Trabajador social',
    'Camillero',
    'Recursos humanos'
  ];

  final _formKey = GlobalKey<FormState>();

  bool isEmailMode =
      false; // Variable para controlar si estamos en modo email o phone

  // Controladores de texto para cada campo
  String? _selectedUserType;
  final TextEditingController idController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNamePaternalController =
      TextEditingController();
  final TextEditingController _lastNameMaternalController =
      TextEditingController();
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final PersonalRepository _personalRepository = PersonalRepository();
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  // Función para validar si el email ya está en uso (RQNF4)
  Future<bool> _isEmailInUse(String email) async {
    try {
      final result = await _personalRepository.getByEmail(email);
      return result != null;
    } catch (e) {
      debugPrint("Error al verificar el email: $e");
      return false;
    }
  }

  // Función para validar si el teléfono ya está en uso (RQNF5)
  Future<bool> _isPhoneInUse(String phone) async {
    try {
      final result = await _personalRepository.getByPhone(phone);
      return result != null;
    } catch (e) {
      debugPrint("Error al verificar el teléfono: $e");
      return false;
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, get the UserCredential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = userCredential.user;
      if (user != null) {
        // Navegar a la pantalla para completar el registro
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompleteStaffRegistration(firebaseUser: user),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in failed: $e'),
        ),
      );
    }
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

                // Campo para el ID
                TextFormField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'Staff ID',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly, // Permitir solo dígitos
                    LengthLimitingTextInputFormatter(
                        8), // Limitar la longitud a 8 dígitos
                  ],
                  validator: (value) {
                    // Validación: 8 dígitos numéricos
                    if (value == null || value.isEmpty) {
                      return 'Please enter your staff ID';
                    }
                    if (value.length != 8) {
                      return 'Staff ID must be exactly 8 digits';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

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

                DropdownButtonFormField<String>(
                  value: _selectedUserType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Usuario',
                    border: OutlineInputBorder(),
                  ),
                  items: userTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(
                        type,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge, // Ajusta el estilo de las opciones
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedUserType = newValue;
                    });
                  },
                  validator: (value) {
                    // Validación: RQNF1
                    if (value == null || value.isEmpty) {
                      return 'Por favor selecciona un tipo de usuario';
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
                      final phoneRegex =
                          RegExp(r'^\d{10}$'); // Arreglar la expresión regular
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
                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$%^&*()!]).{8,}$');

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
                      try {
                        await _personalRepository.insert({
                          'id_personal': idController.text,
                          'nombre': _firstNameController.text,
                          'apellido_paterno': _lastNamePaternalController.text,
                          'apellido_materno': _lastNameMaternalController.text,
                          'tipo': _selectedUserType,
                          'correo_electronico':
                              isEmailMode ? _emailOrPhoneController.text : null,
                          'telefono':
                              isEmailMode ? null : _emailOrPhoneController.text,
                          'contrasena': _passwordController.text,
                        });

                        // Guardar el ID del usuario de forma local
                        await _sharedPreferencesService
                            .saveUserId(idController.text);

                        Navigator.pushNamed(context, '/mainScreen');
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Registration successful'),
                          ),
                        );
                      } catch (e) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Registration failed: $e'),
                          ),
                        );
                      }
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
                  onPressed: _signInWithGoogle,
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
