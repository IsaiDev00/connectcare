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
  final List<String> _sexOptions = ['Masculino', 'Femenino'];
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

  @override
  void dispose() {
    _firstNameController.dispose();
    _paternalLastNameController.dispose();
    _maternalLastNameController.dispose();
    _nssController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Función para seleccionar la fecha de nacimiento
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime(1990);
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Selecciona la fecha de nacimiento',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(), // Puedes personalizar el tema aquí
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
      return 'El campo $fieldName es obligatorio';
    }
    final numericRegex = RegExp(r'^[0-9]+$');
    if (!numericRegex.hasMatch(value)) {
      return 'El campo $fieldName solo permite caracteres numéricos';
    }
    return null;
  }

  // Función para validar campos de texto con límite de caracteres
  String? _validateText(String? value, String fieldName, int maxLength) {
    if (value == null || value.isEmpty) {
      return 'El campo $fieldName es obligatorio';
    }
    if (value.length > maxLength) {
      return 'El campo $fieldName no debe exceder $maxLength caracteres';
    }
    return null;
  }

  // Función para validar la fecha de nacimiento
  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'El campo Fecha de Nacimiento es obligatorio';
    }
    try {
      DateFormat('dd/MM/yyyy').parseStrict(value);
    } catch (e) {
      return 'El formato debe ser DD/MM/AAAA';
    }
    return null;
  }

  // Función para validar las selecciones
  String? _validateSelection(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'El campo $fieldName es obligatorio';
    }
    return null;
  }

  // Función para manejar el envío del formulario
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Asegurar valores para campos opcionales
      final selectedSex = _selectedSex ?? '';
      final selectedBloodGroup = _selectedBloodGroup ?? '';

      // Navegar a la pantalla de triage y pasar los datos necesarios
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Pacient registration'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Nombre(s)
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre(s)',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 500,
                  validator: (value) => _validateText(value, 'Nombre(s)', 500),
                ),
                SizedBox(height: 16.0),

                // Apellido Paterno
                TextFormField(
                  controller: _paternalLastNameController,
                  decoration: InputDecoration(
                    labelText: 'Apellido Paterno',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 500,
                  validator: (value) =>
                      _validateText(value, 'Apellido Paterno', 500),
                ),
                SizedBox(height: 16.0),

                // Apellido Materno
                TextFormField(
                  controller: _maternalLastNameController,
                  decoration: InputDecoration(
                    labelText: 'Apellido Materno',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 500,
                  validator: (value) =>
                      _validateText(value, 'Apellido Materno', 500),
                ),
                SizedBox(height: 16.0),

                // NSS y agregado
                TextFormField(
                  controller: _nssController,
                  decoration: InputDecoration(
                    labelText: 'NSS y Agregado',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 20, // Asumiendo un límite razonable
                  validator: (value) =>
                      _validateNumeric(value, 'NSS y Agregado'),
                ),
                SizedBox(height: 16.0),

                // Fecha de Nacimiento
                TextFormField(
                  controller: _dobController,
                  decoration: InputDecoration(
                    labelText: 'Fecha de Nacimiento (DD/MM/AAAA)',
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
                    labelText: 'Sexo',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedSex,
                  items: _sexOptions
                      .map((sex) => DropdownMenuItem(
                            value: sex,
                            child: Text(sex, 
                            style: TextStyle(
                              fontSize: 13,
                            ),),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSex = value;
                    });
                  },
                  validator: (value) => _validateSelection(value, 'Sexo'),
                ),
                SizedBox(height: 16.0),

                // Grupo y RH
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Grupo y RH',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedBloodGroup,
                  items: _bloodGroupOptions
                      .map((bg) => DropdownMenuItem(
                            value: bg,
                            child: Text(bg,
                            style: TextStyle(
                              fontSize: 13,
                            ),),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBloodGroup = value;
                    });
                  },
                  validator: (value) => _validateSelection(value, 'Grupo y RH'),
                ),
                SizedBox(height: 24.0),

                // Botón de Envío
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Continuar al Triage'),
                ),
              ],
            ),
          ),
        ));
  }
}
