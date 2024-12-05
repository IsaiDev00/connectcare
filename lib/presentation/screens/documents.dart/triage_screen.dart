import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TriageScreen extends StatefulWidget {
  final String firstName;
  final String paternalLastName;
  final String maternalLastName;
  final String nss;
  final String dob;
  final String? sex;
  final String? bloodGroup;
  final DateTime registrationDateTime;

  const TriageScreen({
    super.key,
    required this.firstName,
    required this.paternalLastName,
    required this.maternalLastName,
    required this.nss,
    required this.dob,
    this.sex,
    this.bloodGroup,
    required this.registrationDateTime,
  });

  @override
  _TriageScreen createState() => _TriageScreen();
}

class _TriageScreen extends State<TriageScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final TextEditingController _systolicBPController = TextEditingController();
  final TextEditingController _diastolicBPController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _respiratoryRateController =
      TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _glasgowController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _interrogationSummaryController =
      TextEditingController();
  final TextEditingController _physicalExamController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();

  // Variables para las selecciones
  String? _selectedSAMM;
  String? _selectedSeverityLevel;
  String? _selectedDiagnosticAux;
  bool _canVisitPatient = false;
  String? _selectedArea;
  String? _selectedRoom;
  String? _selectedBed;

  // Opciones de selección
  final List<String> _yesNoOptions = ['Aplica', 'No Aplica'];
  final List<String> _severityLevels = [
    '1 Rojo',
    '2 Naranja',
    '3 Amarillo',
    '4 Verde',
    '5 Azul'
  ];
  final List<String> _diagnosticAuxOptions = [
    'Se solicitan',
    'No se solicitan'
  ];
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> rooms = [];
  List<Map<String, dynamic>> beds = [];

  @override
  void initState() {
    super.initState();
    // Imprimir los datos recibidos para verificar
    print('First Name: ${widget.firstName}');
    print('Paternal Last Name: ${widget.paternalLastName}');
    print('Maternal Last Name: ${widget.maternalLastName}');
    print('NSS: ${widget.nss}');
    print('DOB: ${widget.dob}');
    print('Sex: ${widget.sex}');
    print('Blood Group: ${widget.bloodGroup}');
    print('Registration DateTime: ${widget.registrationDateTime}');
    _fetchServices();
  }

  @override
  void dispose() {
    _systolicBPController.dispose();
    _diastolicBPController.dispose();
    _heartRateController.dispose();
    _respiratoryRateController.dispose();
    _temperatureController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _glucoseController.dispose();
    _glasgowController.dispose();
    _reasonController.dispose();
    _interrogationSummaryController.dispose();
    _physicalExamController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _allergiesController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  String? _validateInteger(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'El campo $fieldName es obligatorio';
    }
    final integerRegex = RegExp(r'^[0-9]+$');
    if (!integerRegex.hasMatch(value)) {
      return 'El campo $fieldName solo permite números enteros';
    }
    return null;
  }

  String? _validateDecimal(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'El campo $fieldName es obligatorio';
    }
    final decimalRegex = RegExp(r'^\d+(\.\d+)?$');
    if (!decimalRegex.hasMatch(value)) {
      return 'El campo $fieldName solo permite números decimales';
    }
    return null;
  }

  String? _validateText(String? value, String fieldName, int maxLength) {
    if (value == null || value.isEmpty) {
      return 'El campo $fieldName es obligatorio';
    }
    if (value.length > maxLength) {
      return 'El campo $fieldName no debe exceder $maxLength caracteres';
    }
    return null;
  }

  String? _validateSelection(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'El campo $fieldName es obligatorio';
    }
    return null;
  }

  Future<void> _fetchServices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/servicio/'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          services = data
              .map(
                  (item) => {'id': item['id_servicio'], 'name': item['nombre']})
              .toList();
        });
      } else {
        throw Exception('Failed to load services');
      }
    } catch (e) {
      print('Error fetching services: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar servicios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchRooms(String serviceId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/sala/sala_servicio/$serviceId'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          rooms = data
              .map((item) =>
                  {'id': item['id_sala'], 'name': item['nombre_sala']})
              .toList();
        });
      } else {
        throw Exception('Failed to load rooms');
      }
    } catch (e) {
      print('Error fetching rooms: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar salas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchBeds(String roomId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/cama/camas_sala/$roomId'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          beds = data
              .map((item) => {
                    'id': item['id_cama'],
                    'name':
                        'Cama ${item['numero_cama']} - Tipo: ${item['tipo']}'
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load beds');
      }
    } catch (e) {
      print('Error fetching beds: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar camas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _registerPaciente() async {
    // Verificar si el formulario es válido
    if (_formKey.currentState!.validate()) {
      // Datos de la pantalla anterior (PRIMERA) desde las propiedades de widget
      final nssPaciente = widget.nss;
      final nombre = widget.firstName;
      final apellidoPaterno = widget.paternalLastName;
      final apellidoMaterno = widget.maternalLastName;
      final sexo = widget.sex ?? '';
      final fechaNacimientoStr = widget.dob;
      final gpoYRh = widget.bloodGroup ?? '';

      // Parsear la fecha de nacimiento y reformatearla
      DateTime fechaNacimiento;
      try {
        fechaNacimiento =
            DateFormat('dd/MM/yyyy').parseStrict(fechaNacimientoStr);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fecha de nacimiento inválida: $fechaNacimientoStr'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final formattedFechaNacimiento =
          DateFormat('yyyy-MM-dd').format(fechaNacimiento);

      // Datos de la pantalla actual (SEGUNDA)
      final estatura = double.parse(_heightController.text);
      final peso = double.parse(_weightController.text);
      final habilitarVisita = _canVisitPatient ? 1 : 0;
      final estado = _estadoController.text;
      final alergias = _allergiesController.text;
      final idCama = _selectedBed != null ? int.parse(_selectedBed!) : null;

      if (idCama == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor, selecciona una cama'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Otros datos
      final fechaEntrada = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final visitantes = 0;

      // Preparar datos para enviar
      Map<String, dynamic> pacienteData = {
        'nss_paciente': nssPaciente,
        'nombre': nombre,
        'apellido_paterno': apellidoPaterno,
        'apellido_materno': apellidoMaterno,
        'lpm': null,
        'estatura': estatura,
        'peso': peso,
        'fecha_entrada': fechaEntrada,
        'habilitar_visita': habilitarVisita,
        'estado': estado,
        'sexo': sexo,
        'fecha_nacimiento':
            formattedFechaNacimiento, // Fecha en formato correcto
        'gpo_y_rh': gpoYRh,
        'visitantes': visitantes,
        'alergias': alergias,
        'id_cama': idCama,
      };

      // Imprimir los datos por consola para verificar
      print('Datos del Paciente a Enviar:');
      print(jsonEncode(pacienteData));

      // Enviar datos al backend
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/paciente/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(pacienteData),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Paciente creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          // Continuar con el registro de Triage
          await _registerTriage();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear el paciente: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear el paciente: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _registerTriage() async {
    // Datos de la pantalla anterior (PRIMERA) desde las propiedades de widget
    final nssPaciente = widget.nss;

    // Datos de la pantalla actual (SEGUNDA)
    final diagnostico = _diagnosisController.text;
    final tratamiento = _treatmentController.text;
    final gCapilar = double.tryParse(_glucoseController.text) ?? 0.0;
    final frecuenciaRespiratoria =
        int.tryParse(_respiratoryRateController.text) ?? 0;
    final frecuenciaCardiaca = int.tryParse(_heartRateController.text) ?? 0;
    final taDiastolica = int.tryParse(_diastolicBPController.text) ?? 0;
    final taSistolica = int.tryParse(_systolicBPController.text) ?? 0;
    final temperatura = double.tryParse(_temperatureController.text) ?? 0.0;
    final peso = double.tryParse(_weightController.text) ?? 0.0;
    final estatura = double.tryParse(_heightController.text) ?? 0.0;
    final escalaGlasgow = int.tryParse(_glasgowController.text) ?? 0;
    final gravedad = _selectedSeverityLevel ?? '';
    final motivo = _reasonController.text;
    final interrogatorio = _interrogationSummaryController.text;
    final exploracionFisica = _physicalExamController.text;
    final auxiliaresDiagnostico = _selectedDiagnosticAux ?? '';

    // fecha_inicio y hora_inicio
    final fechaInicio = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final horaInicio = DateFormat('HH:mm:ss').format(DateTime.now());

    // Preparar datos para enviar
    Map<String, dynamic> triageData = {
      'diagnostico': diagnostico,
      'tratamiento': tratamiento,
      'g_capilar': gCapilar,
      'frecuencia_respiratoria': frecuenciaRespiratoria,
      'frecuencia_cardiaca': frecuenciaCardiaca,
      'ta_diastolica': taDiastolica,
      'ta_sistolica': taSistolica,
      'fecha_fin': null,
      'hora_fin': null,
      'fecha_inicio': fechaInicio,
      'hora_inicio': horaInicio,
      'temperatura': temperatura,
      'peso': peso,
      'estatura': estatura,
      'escala_glasgow': escalaGlasgow,
      'gravedad': gravedad,
      'motivo': motivo,
      'interrogatorio': interrogatorio,
      'exploracion_fisica': exploracionFisica,
      'auxiliares_diagnostico': auxiliaresDiagnostico,
      'nss_paciente': nssPaciente,
    };

    // Imprimir los datos por consola para verificar
    print('Datos del Triage a Enviar:');
    print(jsonEncode(triageData));

    // Enviar datos al backend
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/triage/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(triageData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registro de Triage creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        // Opcional: Navegar a otra pantalla o realizar otras acciones
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error al crear el registro de Triage: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear el registro de Triage: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submitForm() {
    // Imprimir todos los datos por consola antes de realizar el registro
    print('First Name: ${widget.firstName}');
    print('Paternal Last Name: ${widget.paternalLastName}');
    print('Maternal Last Name: ${widget.maternalLastName}');
    print('NSS: ${widget.nss}');
    print('DOB: ${widget.dob}');
    print('Sex: ${widget.sex}');
    print('Blood Group: ${widget.bloodGroup}');
    print('Registration DateTime: ${widget.registrationDateTime}');

    // Imprimir los datos de los campos actuales en TriageScreen
    print('Diagnóstico: ${_diagnosisController.text}');
    print('Tratamiento: ${_treatmentController.text}');
    print('Glucemia Capilar: ${_glucoseController.text}');
    print('Frecuencia Respiratoria: ${_respiratoryRateController.text}');
    print('Frecuencia Cardíaca: ${_heartRateController.text}');
    print('TA Diastólica: ${_diastolicBPController.text}');
    print('TA Sistólica: ${_systolicBPController.text}');
    print('Temperatura: ${_temperatureController.text}');
    print('Peso: ${_weightController.text}');
    print('Estatura: ${_heightController.text}');
    print('Escala de Glasgow: ${_glasgowController.text}');
    print('Gravedad: $_selectedSeverityLevel');
    print('Motivo: ${_reasonController.text}');
    print('Interrogatorio: ${_interrogationSummaryController.text}');
    print('Exploración Física: ${_physicalExamController.text}');
    print('Auxiliares de Diagnóstico: $_selectedDiagnosticAux');

    // Llamar al registro de paciente
    _registerPaciente();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Triage'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Tensión Arterial Sistólica
              TextFormField(
                controller: _systolicBPController,
                decoration: InputDecoration(
                  labelText: 'Tensión Arterial Sistólica',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    _validateInteger(value, 'Tensión Arterial Sistólica'),
              ),
              SizedBox(height: 16.0),

              // Tensión Arterial Diastólica
              TextFormField(
                controller: _diastolicBPController,
                decoration: InputDecoration(
                  labelText: 'Tensión Arterial Diastólica',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    _validateInteger(value, 'Tensión Arterial Diastólica'),
              ),
              SizedBox(height: 16.0),

              // Frecuencia Cardiaca
              TextFormField(
                controller: _heartRateController,
                decoration: InputDecoration(
                  labelText: 'Frecuencia Cardiaca',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    _validateInteger(value, 'Frecuencia Cardiaca'),
              ),
              SizedBox(height: 16.0),

              // Frecuencia Respiratoria
              TextFormField(
                controller: _respiratoryRateController,
                decoration: InputDecoration(
                  labelText: 'Frecuencia Respiratoria',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    _validateInteger(value, 'Frecuencia Respiratoria'),
              ),
              SizedBox(height: 16.0),

              // Temperatura
              TextFormField(
                controller: _temperatureController,
                decoration: InputDecoration(
                  labelText: 'Temperatura',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => _validateDecimal(value, 'Temperatura'),
              ),
              SizedBox(height: 16.0),

              // Peso
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Peso (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => _validateDecimal(value, 'Peso'),
              ),
              SizedBox(height: 16.0),

              // Estatura
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: 'Estatura (mt)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => _validateDecimal(value, 'Estatura'),
              ),
              SizedBox(height: 16.0),

              // Glucemia Capilar
              TextFormField(
                controller: _glucoseController,
                decoration: InputDecoration(
                  labelText: 'Glucemia Capilar',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    _validateDecimal(value, 'Glucemia Capilar'),
              ),
              SizedBox(height: 16.0),

              // Escala de Glasgow
              TextFormField(
                controller: _glasgowController,
                decoration: InputDecoration(
                  labelText: 'Escala de Glasgow',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    _validateInteger(value, 'Escala de Glasgow'),
              ),
              SizedBox(height: 16.0),

              // Nivel de Gravedad
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Nivel de Gravedad',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSeverityLevel,
                items: _severityLevels
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSeverityLevel = value;
                  });
                },
                validator: (value) =>
                    _validateSelection(value, 'Nivel de Gravedad'),
              ),
              SizedBox(height: 16.0),

              // Motivo de Atención
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: 'Motivo de Atención',
                  border: OutlineInputBorder(),
                ),
                maxLength: 500,
                maxLines: 3,
                validator: (value) =>
                    _validateText(value, 'Motivo de Atención', 500),
              ),
              SizedBox(height: 16.0),

              // Resumen del Interrogatorio
              TextFormField(
                controller: _interrogationSummaryController,
                decoration: InputDecoration(
                  labelText: 'Resumen del Interrogatorio',
                  border: OutlineInputBorder(),
                ),
                maxLength: 500,
                maxLines: 3,
                validator: (value) =>
                    _validateText(value, 'Resumen del Interrogatorio', 500),
              ),
              SizedBox(height: 16.0),

              // Exploración Física
              TextFormField(
                controller: _physicalExamController,
                decoration: InputDecoration(
                  labelText: 'Exploración Física',
                  border: OutlineInputBorder(),
                ),
                maxLength: 500,
                maxLines: 3,
                validator: (value) =>
                    _validateText(value, 'Exploración Física', 500),
              ),
              SizedBox(height: 16.0),

              // Auxiliares de Diagnóstico
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Auxiliares de Diagnóstico',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDiagnosticAux,
                items: _diagnosticAuxOptions
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDiagnosticAux = value;
                  });
                },
                validator: (value) =>
                    _validateSelection(value, 'Auxiliares de Diagnóstico'),
              ),
              SizedBox(height: 16.0),

              // Diagnóstico(s)
              TextFormField(
                controller: _diagnosisController,
                decoration: InputDecoration(
                  labelText: 'Diagnóstico(s)',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                validator: (value) =>
                    _validateText(value, 'Diagnóstico(s)', 100),
              ),
              SizedBox(height: 16.0),

              // Estado
              TextFormField(
                controller: _estadoController,
                decoration: InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                maxLength: 50,
                validator: (value) => _validateText(value, 'Estado', 50),
              ),
              SizedBox(height: 16.0),

              // Tratamiento
              TextFormField(
                controller: _treatmentController,
                decoration: InputDecoration(
                  labelText: 'Tratamiento',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                validator: (value) => _validateText(value, 'Tratamiento', 100),
              ),
              SizedBox(height: 16.0),

              // Uso de SAMM
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Uso de SAMM',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSAMM,
                items: _yesNoOptions
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSAMM = value;
                  });
                },
                validator: (value) => _validateSelection(value, 'Uso de SAMM'),
              ),
              SizedBox(height: 24.0),

              // Pregunta si se puede visitar al paciente
              SwitchListTile(
                title: Text('¿Se puede visitar al paciente?'),
                value: _canVisitPatient,
                onChanged: (value) {
                  setState(() {
                    _canVisitPatient = value;
                  });
                },
              ),
              SizedBox(height: 16.0),

              // Pregunta si el paciente tiene alergias
              TextFormField(
                controller: _allergiesController,
                decoration: InputDecoration(
                  labelText: 'Alergias',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                validator: (value) => _validateText(value, 'Alergias', 100),
              ),
              SizedBox(height: 16.0),

              // Seleccionar área (Servicio)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Área',
                  border: OutlineInputBorder(),
                ),
                value: _selectedArea,
                items: services
                    .map((service) => DropdownMenuItem(
                          value: service['id'].toString(),
                          child: Text(service['name']),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedArea = value;
                    _selectedRoom = null;
                    _selectedBed = null;
                    rooms = [];
                    beds = [];
                    _fetchRooms(value!);
                  });
                },
                validator: (value) => _validateSelection(value, 'Área'),
              ),
              SizedBox(height: 16.0),

              // Mostrar el selector de sala solo si hay salas disponibles
              if (rooms.isNotEmpty)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Cuarto',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedRoom,
                  items: rooms
                      .map((room) => DropdownMenuItem(
                            value: room['id'].toString(),
                            child: Text(room['name']),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRoom = value;
                      _selectedBed = null;
                      beds = [];
                      _fetchBeds(value!);
                    });
                  },
                  validator: (value) => _validateSelection(value, 'Cuarto'),
                ),
              SizedBox(height: 16.0),

              // Mostrar el selector de cama solo si una sala ha sido seleccionada
              if (beds.isNotEmpty)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Cama',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedBed,
                  items: beds
                      .map((bed) => DropdownMenuItem(
                            value: bed['id'].toString(),
                            child: Text(bed['name']),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBed = value;
                    });
                  },
                  validator: (value) => _validateSelection(value, 'Cama'),
                ),
              SizedBox(height: 16.0),

              // Botón de Envío
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Registrar Triage'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
