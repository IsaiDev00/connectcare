import 'dart:async';
import 'package:connectcare/presentation/screens/doctor/documents.dart/triage_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientRegScreen extends StatefulWidget {
  const PatientRegScreen({super.key});

  @override
  PatientRegState createState() => PatientRegState();
}

class PatientRegState extends State<PatientRegScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _paternalLastNameController =
      TextEditingController();
  final TextEditingController _maternalLastNameController =
      TextEditingController();
  final TextEditingController _nssController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  // Variables para las selecciones
  String? _selectedSex;
  String? _selectedBloodGroup;

  // Opciones de selección
  final List<String> _sexOptions = ['Male', 'Female'];
  final List<String> _bloodGroupOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  // Fecha de registro (marca de tiempo)
  final DateTime _registrationDateTime = DateTime.now();

  // Para mostrar la hora actual y tiempo de inicio/fin
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  late DateTime startTime;
  DateTime? endTime;

  @override
  void initState() {
    super.initState();
    // Guardamos la hora de inicio
    startTime = DateTime.now();
    // Actualizamos la hora actual cada segundo
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _firstNameController.dispose();
    _paternalLastNameController.dispose();
    _maternalLastNameController.dispose();
    _nssController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Función para seleccionar la fecha de nacimiento (visible al usuario, cambiar a inglés)
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime(1990);
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select the date of birth',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Función para validar que solo se ingresen números
  String? _validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    final numericRegex = RegExp(r'^[0-9]+$');
    if (!numericRegex.hasMatch(value)) {
      return '$fieldName must be numeric only';
    }
    return null;
  }

  // Función para validar campos de texto con límite de caracteres
  String? _validateText(String? value, String fieldName, int maxLength) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }

  // Función para validar la fecha de nacimiento
  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of Birth is required';
    }
    try {
      DateFormat('dd/MM/yyyy').parseStrict(value);
    } catch (e) {
      return 'The format must be DD/MM/YYYY';
    }
    return null;
  }

  // Función para validar las selecciones
  String? _validateSelection(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Función para manejar el envío del formulario
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Asegurar valores para campos opcionales
      final selectedSex = _selectedSex ?? '';
      final selectedBloodGroup = _selectedBloodGroup ?? '';

      // Hora fin
      endTime = DateTime.now();
      final endTimeStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(endTime!);

      // Mostrar mensaje con hora fin
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Finish Time: $endTimeStr'),
          backgroundColor: Colors.blue,
        ),
      );

      // Navegar a la pantalla de triage después de mostrar el SnackBar
      // Esperamos un pequeño delay para que el usuario alcance a ver el SnackBar
      Future.delayed(Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TriageScreen(
              firstName: _firstNameController.text.trim(),
              paternalLastName: _paternalLastNameController.text.trim(),
              maternalLastName: _maternalLastNameController.text.trim(),
              nss: _nssController.text.trim(),
              dob: _dobController.text.trim(),
              sex: selectedSex,
              bloodGroup: selectedBloodGroup,
              registrationDateTime: _registrationDateTime,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final startDateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(startTime);
    final currentTimeStr = DateFormat('HH:mm:ss').format(_currentTime);

    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Registration'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Mostrar fecha y hora de inicio siempre visible
              Text(
                'Start Time: $startDateStr',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              // Mostrar hora actual actualizándose cada segundo
              Text(
                'Current Time: $currentTimeStr',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),

              // Nombre(s)
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                maxLength: 500,
                validator: (value) => _validateText(value, 'First Name', 500),
              ),
              SizedBox(height: 16.0),

              // Apellido Paterno
              TextFormField(
                controller: _paternalLastNameController,
                decoration: InputDecoration(
                  labelText: 'Paternal Last Name',
                  border: OutlineInputBorder(),
                ),
                maxLength: 500,
                validator: (value) =>
                    _validateText(value, 'Paternal Last Name', 500),
              ),
              SizedBox(height: 16.0),

              // Apellido Materno
              TextFormField(
                controller: _maternalLastNameController,
                decoration: InputDecoration(
                  labelText: 'Maternal Last Name',
                  border: OutlineInputBorder(),
                ),
                maxLength: 500,
                validator: (value) =>
                    _validateText(value, 'Maternal Last Name', 500),
              ),
              SizedBox(height: 16.0),

              // NSS y agregado
              TextFormField(
                controller: _nssController,
                decoration: InputDecoration(
                  labelText: 'NSS and Additional',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 20,
                validator: (value) =>
                    _validateNumeric(value, 'NSS and Additional'),
              ),
              SizedBox(height: 16.0),

              // Fecha de Nacimiento
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth (DD/MM/YYYY)',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: _validateDate,
              ),
              SizedBox(height: 16.0),

              // Sexo
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Sex',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSex,
                items: _sexOptions
                    .map((sex) => DropdownMenuItem(
                          value: sex,
                          child: Text(
                            sex,
                            style: TextStyle(fontSize: 13),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSex = value;
                  });
                },
                validator: (value) => _validateSelection(value, 'Sex'),
              ),
              SizedBox(height: 16.0),

              // Grupo y RH
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Blood Group and RH',
                  border: OutlineInputBorder(),
                ),
                value: _selectedBloodGroup,
                items: _bloodGroupOptions
                    .map((bg) => DropdownMenuItem(
                          value: bg,
                          child: Text(
                            bg,
                            style: TextStyle(fontSize: 13),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBloodGroup = value;
                  });
                },
                validator: (value) =>
                    _validateSelection(value, 'Blood Group and RH'),
              ),
              SizedBox(height: 24.0),

              // Botón de Envío
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Continue to Triage'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
