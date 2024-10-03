import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FamilyRegistration extends StatefulWidget {
  const FamilyRegistration({super.key});

  @override
  FamilyRegistrationState createState() => FamilyRegistrationState();
}

class FamilyRegistrationState extends State<FamilyRegistration> {
  bool isEmailMode =
      false; // Variable para controlar si estamos en modo email o phone
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: Text('Register with ConnectCare'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: brightness == Brightness.dark
              ? Colors.transparent
              : Colors.white, // Ajusta el color según el tema
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light // Íconos blancos en modo oscuro
              : Brightness.dark, // Íconos oscuros en modo claro
          statusBarBrightness: brightness == Brightness.dark
              ? Brightness.dark
              : Brightness.light, // Ajuste adicional para iOS
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 30),
              // Campo para el nombre
              TextField(
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),

              // Campo para el apellido paterno
              TextField(
                decoration: InputDecoration(
                  labelText: 'Last Name (Paternal)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),

              // Campo para el apellido materno
              TextField(
                decoration: InputDecoration(
                  labelText: 'Last Name (Maternal)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),

              // Campo dinámico para el número de teléfono o correo electrónico
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: isEmailMode ? 'Email Address' : 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: isEmailMode
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
              ),
              SizedBox(height: 15),

              // Campo para la contraseña
              TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 15),

              // Campo para confirmar la contraseña
              TextField(
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 30),

              // Botón para continuar
              ElevatedButton(
                onPressed: () {
                  // Lógica para registrar al familiar
                },
                child: Text(
                  'Continue',
                ),
              ),
              SizedBox(height: 20),

              // Texto "or"
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("or"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 20),

              // Botón dinámico para alternar entre Email y Teléfono
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isEmailMode = !isEmailMode; // Alternar entre email y phone
                    _controller.clear(); // Limpiar el TextField al cambiar
                  });
                },
                icon: Icon(
                  isEmailMode ? Icons.phone : Icons.email_outlined,
                  color: Colors.black,
                ),
                label: Text(
                  isEmailMode ? 'Continue with Phone' : 'Continue with Email',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
              SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed: () {
                  // Lógica para iniciar sesión con Facebook
                },
                icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
                label: Text('Continue with Facebook',
                    style: Theme.of(context).textTheme.headlineSmall),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
              SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed: () {
                  // Lógica para iniciar sesión con Google
                },
                icon: FaIcon(FontAwesomeIcons.google, color: Colors.red),
                label: Text('Continue with Google',
                    style: Theme.of(context).textTheme.headlineSmall),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
              SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed: () {
                  // Lógica para iniciar sesión con Apple
                },
                icon: FaIcon(FontAwesomeIcons.apple, color: Colors.black),
                label: Text('Continue with Apple',
                    style: Theme.of(context).textTheme.headlineSmall),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
