import 'dart:async';
import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:http/http.dart' as http;

// Modelo para Reagent (solo datos)
class Reagent {
  String name;
  String concentration;

  Reagent({
    required this.name,
    required this.concentration,
  });
}

// Modelo para Medication
class Medication {
  List<Reagent> reagents;
  int quantity;
  String brand;
  String route;
  String type;

  Medication({
    required this.reagents,
    required this.quantity,
    required this.brand,
    required this.route,
    required this.type,
  });
}

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
  _TriageScreenState createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  String cluesdoc = "CSSSA009635";
  final int id_medico = 19;
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  // Lista de Medicamentos Solicitados
  List<Medication> medications = [];

  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
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
  final TextEditingController _statusController = TextEditingController();

  int idTriage = 0;

  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  // Variables de selección
  String? _selectedSAMM;
  String? _selectedSeverityLevel;
  String? _selectedDiagnosticAux;
  bool _canVisitPatient = false;
  String? _selectedArea;
  String? _selectedRoom;
  String? _selectedBed;

  // Opciones de selección
  final List<String> _yesNoOptions = ['Applies', 'Does Not Apply'];
  final List<String> _severityLevels = [
    '1 Red',
    '2 Orange',
    '3 Yellow',
    '4 Green',
    '5 Blue'
  ];
  final List<String> _diagnosticAuxOptions = ['Requested', 'Not Requested'];
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> rooms = [];
  List<Map<String, dynamic>> beds = [];

  // Marcas de tiempo
  late DateTime triageStartTime;
  DateTime? triageEndTime;

  @override
  void initState() {
    super.initState();
    // Al iniciar la pantalla (inicio del triage)
    triageStartTime = DateTime.now();

    _currentTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });

    _initializeData();
    _fetchServices();
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _saveData(cluesdoc); // Guardar valores iniciales
    setState(() {}); // Forzar reconstrucción para sincronizar UI
  }

  // Guardar datos en SharedPreferences
  Future<void> _saveData(String newClues) async {
    await _sharedPreferencesService.saveClues(newClues);
  }

  // Métodos de validación
  String? _validateInteger(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    final integerRegex = RegExp(r'^[0-9]+$');
    if (!integerRegex.hasMatch(value)) {
      return '$fieldName must be an integer';
    }
    return null;
  }

  String? _validateDecimal(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    final decimalRegex = RegExp(r'^\d+(\.\d+)?$');
    if (!decimalRegex.hasMatch(value)) {
      return '$fieldName must be a decimal number';
    }
    return null;
  }

  String? _validateText(String? value, String fieldName, int maxLength) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }

  String? _validateSelection(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<void> _fetchServices() async {
    try {
      final clues = await _sharedPreferencesService.getClues();
      final response = await http.get(Uri.parse('$baseUrl/servicio/$clues'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          services = data
              .map((item) => {
                    'id': item['id_servicio'],
                    'service_name': item['nombre_servicio']
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load services');
      }
    } catch (e) {
      print('Error fetching services: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading services: $e'),
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
          content: Text('Error loading rooms: $e'),
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
              .where((item) => int.parse(item['en_uso'].toString()) == 0)
              .map((item) => {
                    'id': item['id_cama'],
                    'name':
                        'Bed ${item['numero_cama']} - Type: ${item['tipo']}',
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
          content: Text('Error loading beds: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _registerPatient() async {
    if (_formKey.currentState!.validate()) {
      final nssPatient = widget.nss;
      final firstName = widget.firstName;
      final paternalLastName = widget.paternalLastName;
      final maternalLastName = widget.maternalLastName;
      final sex = widget.sex ?? '';
      final dobStr = widget.dob;
      final bloodGroup = widget.bloodGroup ?? '';

      DateTime dob;
      try {
        dob = DateFormat('dd/MM/yyyy').parseStrict(dobStr);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid date of birth: $dobStr'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final formattedDOB = DateFormat('yyyy-MM-dd').format(dob);

      final height = double.parse(_heightController.text);
      final weight = double.parse(_weightController.text);
      final canVisit = _canVisitPatient ? 1 : 0;
      final status = _statusController.text;
      final allergies = _allergiesController.text;
      final bedId = _selectedBed != null ? int.parse(_selectedBed!) : null;

      if (bedId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a bed'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final entryDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final visitors = 0;

      Map<String, dynamic> patientData = {
        'nss_paciente': nssPatient,
        'nombre': firstName,
        'apellido_paterno': paternalLastName,
        'apellido_materno': maternalLastName,
        'lpm': null,
        'estatura': height,
        'peso': weight,
        'fecha_entrada': entryDate,
        'habilitar_visita': canVisit,
        'estado': status,
        'sexo': sex,
        'fecha_nacimiento': formattedDOB,
        'gpo_y_rh': bloodGroup,
        'visitantes': visitors,
        'alergias': allergies,
        'id_cama': bedId
      };

      print('Patient Data to Send:');
      print(jsonEncode(patientData));

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/paciente/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(patientData),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Patient created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          await _registerTriage();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating patient: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating patient: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _registerTriage() async {
    triageEndTime = DateTime.now();
    final endDate = DateFormat('yyyy-MM-dd').format(triageEndTime!);
    final endTime = DateFormat('HH:mm:ss').format(triageEndTime!);

    final nssPatient = widget.nss;

    final diagnosis = _diagnosisController.text;
    final treatment = _treatmentController.text;
    final glucose = double.tryParse(_glucoseController.text) ?? 0.0;
    final respiratoryRate = int.tryParse(_respiratoryRateController.text) ?? 0;
    final heartRate = int.tryParse(_heartRateController.text) ?? 0;
    final diastolicBP = int.tryParse(_diastolicBPController.text) ?? 0;
    final systolicBP = int.tryParse(_systolicBPController.text) ?? 0;
    final temperature = double.tryParse(_temperatureController.text) ?? 0.0;
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final height = double.tryParse(_heightController.text) ?? 0.0;
    final glasgowScale = int.tryParse(_glasgowController.text) ?? 0;
    final severity = _selectedSeverityLevel ?? '';
    final reason = _reasonController.text;
    final interrogationSummary = _interrogationSummaryController.text;
    final physicalExam = _physicalExamController.text;
    final diagnosticAux = _selectedDiagnosticAux ?? '';

    final startDate = DateFormat('yyyy-MM-dd').format(triageStartTime);
    final startTime = DateFormat('HH:mm:ss').format(triageStartTime);

    Map<String, dynamic> triageData = {
      'diagnostico': diagnosis,
      'tratamiento': treatment,
      'g_capilar': glucose,
      'frecuencia_respiratoria': respiratoryRate,
      'frecuencia_cardiaca': heartRate,
      'ta_diastolica': diastolicBP,
      'ta_sistolica': systolicBP,
      'fecha_fin': endDate,
      'hora_fin': endTime,
      'fecha_inicio': startDate,
      'hora_inicio': startTime,
      'temperatura': temperature,
      'peso': weight,
      'estatura': height,
      'escala_glasgow': glasgowScale,
      'gravedad': severity,
      'motivo': reason,
      'interrogatorio': interrogationSummary,
      'exploracion_fisica': physicalExam,
      'auxiliares_diagnostico': diagnosticAux,
      'nss_paciente': nssPatient,
      'id_medico': id_medico
    };

    print('Triage Data to Send: ${jsonEncode(triageData)}');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/triage/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(triageData),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        idTriage = responseData['id'];
        print('Triage ID created: $idTriage');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Triage record created successfully, ID: $idTriage'),
            backgroundColor: Colors.green,
          ),
        );

        await _registerMedication();

        // Mostrar en terminal la hora fin y fecha fin
        print('Triage End Date and Time: $endDate $endTime');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating triage record: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating triage record: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _registerMedication() async {
    if (idTriage == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please register the triage record first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    for (int index = 0; index < medications.length; index++) {
      final medication = medications[index];
      final nssPaciente = widget.nss;
      final fuente = "Triage";
      final idFuente = idTriage;
      final marca = medication.brand;
      final viaTrans = medication.route;
      final cantidad = medication.quantity;
      final unidadMedida = medication.type;

      List<String> nombresReagentes =
          medication.reagents.map((r) => r.name).toList();
      List<String> concentraciones =
          medication.reagents.map((r) => r.concentration ?? '').toList();

      String concentracion = concentraciones.join(',');
      String reactivo = nombresReagentes.join(',');

      Map<String, dynamic> medicationData = {
        'concentracion': concentracion,
        'nss_paciente': nssPaciente,
        'fuente_tipo': fuente,
        'fuente_id': idFuente,
        'nombre_reactivo': reactivo,
        'marca': marca,
        'via_administracion': viaTrans,
        'cantidad': cantidad,
        'unidad': unidadMedida,
      };

      print('Medication Data to Send: ${jsonEncode(medicationData)}');

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/solicitud_medicamento/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(medicationData),
        );

        if (response.statusCode == 201) {
          print('Medication request created successfully.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Medication request created successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Error creating medication request: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating medication request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      medications.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All medication requests processed successfully.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _submitForm() {
    print('First Name: ${widget.firstName}');
    print('Paternal Last Name: ${widget.paternalLastName}');
    print('Maternal Last Name: ${widget.maternalLastName}');
    print('NSS: ${widget.nss}');
    print('DOB: ${widget.dob}');
    print('Sex: ${widget.sex}');
    print('Blood Group: ${widget.bloodGroup}');
    print('Registration DateTime: ${widget.registrationDateTime}');

    print('Triage End Attempt: ${DateTime.now()}');

    _registerPatient();
  }

  void _requestMedication() {
    showDialog(
      context: context,
      builder: (context) {
        return MedicationDialog(
          onSave: (Medication medication) {
            setState(() {
              medications.add(medication);
            });
            print('Medication added. Total medications: ${medications.length}');
          },
        );
      },
    );
  }

  void _removeMedication(int index) {
    setState(() {
      medications.removeAt(index);
    });
    print('Medication removed. Total medications: ${medications.length}');
  }

  @override
  Widget build(BuildContext context) {
    final startDateStr = DateFormat('yyyy-MM-dd').format(triageStartTime);
    final startTimeStr = DateFormat('HH:mm:ss').format(triageStartTime);

    return Scaffold(
      appBar: AppBar(
        title: Text('Triage Registration'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Mostrar fecha y hora de inicio del triage siempre visible
              Text(
                'Triage Start: $startDateStr $startTimeStr',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              // Mostrar hora actual, actualizándose cada segundo
              Text(
                'Time Elapsed: ${DateFormat('HH:mm:ss').format(_currentTime)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _systolicBPController,
                decoration: InputDecoration(
                  labelText: 'Systolic Blood Pressure',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    _validateInteger(value, 'Systolic Blood Pressure'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _diastolicBPController,
                decoration: InputDecoration(
                  labelText: 'Diastolic Blood Pressure',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    _validateInteger(value, 'Diastolic Blood Pressure'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _heartRateController,
                decoration: InputDecoration(
                  labelText: 'Heart Rate',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => _validateInteger(value, 'Heart Rate'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _respiratoryRateController,
                decoration: InputDecoration(
                  labelText: 'Respiratory Rate',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    _validateInteger(value, 'Respiratory Rate'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _temperatureController,
                decoration: InputDecoration(
                  labelText: 'Temperature',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => _validateDecimal(value, 'Temperature'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => _validateDecimal(value, 'Weight'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: 'Height (m)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => _validateDecimal(value, 'Height'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _glucoseController,
                decoration: InputDecoration(
                  labelText: 'Capillary Glucose',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    _validateDecimal(value, 'Capillary Glucose'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _glasgowController,
                decoration: InputDecoration(
                  labelText: 'Glasgow Scale',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => _validateInteger(value, 'Glasgow Scale'),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Severity Level',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSeverityLevel,
                items: _severityLevels
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(
                            level,
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSeverityLevel = value;
                  });
                },
                validator: (value) =>
                    _validateSelection(value, 'Severity Level'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: 'Reason for Attention',
                  border: OutlineInputBorder(),
                ),
                maxLength: 500,
                maxLines: 3,
                validator: (value) =>
                    _validateText(value, 'Reason for Attention', 500),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _interrogationSummaryController,
                decoration: InputDecoration(
                  labelText: 'Interrogation Summary',
                  border: OutlineInputBorder(),
                ),
                maxLength: 500,
                maxLines: 3,
                validator: (value) =>
                    _validateText(value, 'Interrogation Summary', 500),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _physicalExamController,
                decoration: InputDecoration(
                  labelText: 'Physical Exam',
                  border: OutlineInputBorder(),
                ),
                maxLength: 500,
                maxLines: 3,
                validator: (value) =>
                    _validateText(value, 'Physical Exam', 500),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Diagnostic Auxiliaries',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDiagnosticAux,
                items: _diagnosticAuxOptions
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDiagnosticAux = value;
                  });
                },
                validator: (value) =>
                    _validateSelection(value, 'Diagnostic Auxiliaries'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _diagnosisController,
                decoration: InputDecoration(
                  labelText: 'Diagnoses',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                validator: (value) => _validateText(value, 'Diagnoses', 100),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _statusController,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                maxLength: 50,
                validator: (value) => _validateText(value, 'Status', 50),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _treatmentController,
                decoration: InputDecoration(
                  labelText: 'Treatment',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                validator: (value) => _validateText(value, 'Treatment', 100),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Usage of SAMM',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSAMM,
                items: _yesNoOptions
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSAMM = value;
                  });
                },
                validator: (value) =>
                    _validateSelection(value, 'Usage of SAMM'),
              ),
              SizedBox(height: 24.0),
              SwitchListTile(
                title: Text('Can Visit Patient?'),
                value: _canVisitPatient,
                onChanged: (value) {
                  setState(() {
                    _canVisitPatient = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _allergiesController,
                decoration: InputDecoration(
                  labelText: 'Allergies',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                validator: (value) => _validateText(value, 'Allergies', 100),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Area',
                  border: OutlineInputBorder(),
                ),
                value: _selectedArea,
                items: services
                    .map((service) => DropdownMenuItem(
                          value: service['id'].toString(),
                          child: Text(
                            service['service_name'],
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
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
                validator: (value) => _validateSelection(value, 'Area'),
              ),
              SizedBox(height: 16.0),
              if (rooms.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Flexible(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Room',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedRoom,
                          items: rooms
                              .map((room) => DropdownMenuItem(
                                    value: room['id'].toString(),
                                    child: Text(
                                      room['name'],
                                      style: TextStyle(
                                        fontSize: 13,
                                      ),
                                    ),
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
                          validator: (value) =>
                              _validateSelection(value, 'Room'),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 16.0),
              if (beds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Flexible(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Bed',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedBed,
                          items: beds
                              .map((bed) => DropdownMenuItem(
                                    value: bed['id'].toString(),
                                    child: Text(
                                      bed['name'],
                                      style: TextStyle(
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBed = value;
                            });
                          },
                          validator: (value) =>
                              _validateSelection(value, 'Bed'),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 16.0),

              // Lista de Medicamentos
              if (medications.isNotEmpty) ...[
                SizedBox(height: 24.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Requested Medications:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: medications.length,
                  itemBuilder: (BuildContext context, int index) {
                    final medication = medications[index];

                    return Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Medication ${index + 1}:',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _removeMedication(index),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                                'Quantity: ${medication.quantity} ${medication.type}'),
                            const SizedBox(height: 4.0),
                            for (var reagent in medication.reagents)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text(
                                    '- ${reagent.name.isNotEmpty ? reagent.name : 'Unnamed Reagent'} (${reagent.concentration.isNotEmpty ? reagent.concentration : 'No concentration'})'),
                              ),
                            const SizedBox(height: 4.0),
                            if (medication.brand.isNotEmpty)
                              Text('Brand: ${medication.brand}')
                            else
                              const Text('No brand specified'),
                            if (medication.route.isNotEmpty)
                              Text('Route: ${medication.route}')
                            else
                              const Text('No route specified'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],

              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _requestMedication,
                child: Text('Request Medications'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Register Triage'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReagentForm {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController concentrationController = TextEditingController();

  void dispose() {
    nameController.dispose();
    concentrationController.dispose();
  }
}

class MedicationDialog extends StatefulWidget {
  final Function(Medication) onSave;

  const MedicationDialog({super.key, required this.onSave});

  @override
  _MedicationDialogState createState() => _MedicationDialogState();
}

class _MedicationDialogState extends State<MedicationDialog> {
  final _medicationFormKey = GlobalKey<FormState>();
  List<ReagentForm> reagentForms = [
    ReagentForm(),
  ];
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();
  String? _selectedType;

  final Map<String, List<String>> _typeCategories = {
    'Solid Presentations': [
      'Tablets',
      'Pills',
      'Capsules',
      'Granules',
      'Packets',
      'Suppositories',
      'Vaginal Inserts',
    ],
    'Liquid Presentations': [
      'Milliliters (ml)',
      'Liters (L)',
      'Bottles',
      'Ampoules',
      'Vials',
      'Drops',
    ],
    'Weight Measurement Units': [
      'Milligrams (mg)',
      'Grams (g)',
      'Micrograms (mcg)',
      'International Units (IU)',
    ],
    'Topical Presentations': [
      'Tubes',
      'Patches',
      'Sprays',
      'Aerosols',
      'Ointments',
      'Topical Solutions',
    ],
    'Ophthalmic and Otic Presentations': [
      'Bottles',
      'Single-Dose Units',
    ],
    'Inhaled Presentations': [
      'Cartridges',
      'Doses',
      'Nebulizations',
    ],
    'Other Specific Presentations': [
      'Transdermal Patches',
      'Implants',
      'Medical Devices',
      'Bags',
      'Application Units',
    ],
    'General Units': [
      'Boxes',
      'Packages',
      'Blisters',
      'Kits',
    ],
    'Pediatric Specific Units': [
      'Pediatric Doses',
      'Small Bottles',
      'Infant Suppositories',
    ],
    'Customizable Options': [
      'Pre-filled Syringes',
      'Controlled Release Systems',
      'Dilution Solutions',
    ],
  };

  List<String> get _allTypes =>
      _typeCategories.values.expand((x) => x).toList();

  @override
  void dispose() {
    _quantityController.dispose();
    _brandController.dispose();
    _routeController.dispose();
    for (var reagentForm in reagentForms) {
      reagentForm.dispose();
    }
    super.dispose();
  }

  void _showTypeSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';
        String? selectedTypeLocal = _selectedType;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            List<String> filteredTypes = _allTypes
                .where((type) =>
                    type.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();
            return AlertDialog(
              title: Text('Select Medication Type'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Type',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setStateDialog(() {
                        searchQuery = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _typeCategories.entries.map((entry) {
                          String category = entry.key;
                          List<String> types = entry.value;
                          List<String> visibleTypes = types
                              .where((type) => type
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()))
                              .toList();
                          if (visibleTypes.isEmpty) return Container();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              ...visibleTypes
                                  .map((type) => RadioListTile<String>(
                                        title: Text(type),
                                        value: type,
                                        groupValue: selectedTypeLocal,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedType = value;
                                            selectedTypeLocal = value;
                                          });
                                          setStateDialog(() {});
                                          Navigator.of(context).pop();
                                        },
                                      )),
                              SizedBox(height: 10),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addReagent() {
    if (reagentForms.length < 10) {
      setState(() {
        reagentForms.add(ReagentForm());
      });
      print('Reagent added. Total reagents: ${reagentForms.length}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot add more than 10 reagents.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeReagent(int index) {
    if (reagentForms.length > 1) {
      setState(() {
        reagentForms.removeAt(index);
      });
      print('Reagent removed. Total reagents: ${reagentForms.length}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('At least one reagent is required.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Request Medication'),
      content: SingleChildScrollView(
        child: Form(
          key: _medicationFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: reagentForms.asMap().entries.map((entry) {
                  int index = entry.key;
                  ReagentForm reagentForm = entry.value;
                  return ReagentWidget(
                    reagentForm: reagentForm,
                    index: index,
                    onRemove: () => _removeReagent(index),
                  );
                }).toList(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _addReagent,
                  icon: Icon(Icons.add),
                  label: Text('Add Reagent'),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(
                  labelText: 'Brand (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _routeController,
                decoration: InputDecoration(
                  labelText: 'Route of Administration',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Route of Administration is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Quantity is required';
                        }
                        final intValue = int.tryParse(value);
                        if (intValue == null || intValue <= 0) {
                          return 'Enter a valid quantity';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Text(
                      _selectedType ?? 'Select Type',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _showTypeSelectionDialog,
                child: Text(
                  _selectedType == null ? 'Select Type' : 'Change Type',
                ),
              ),
              SizedBox(height: 4.0),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            print('Cancel button pressed.');
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_medicationFormKey.currentState!.validate()) {
              if (_selectedType == null || _selectedType!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please select a type for the medication.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              bool reagentsValid = true;
              for (var reagentForm in reagentForms) {
                if (reagentForm.nameController.text.isEmpty) {
                  reagentsValid = false;
                  break;
                }
              }
              if (!reagentsValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('All reagents must have a name.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Medication newMedication = Medication(
                reagents: reagentForms
                    .map((r) => Reagent(
                          name: r.nameController.text,
                          concentration: r.concentrationController.text,
                        ))
                    .toList(),
                quantity: int.parse(_quantityController.text),
                brand: _brandController.text,
                route: _routeController.text,
                type: _selectedType!,
              );

              widget.onSave(newMedication);

              Navigator.of(context).pop();
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

class ReagentWidget extends StatefulWidget {
  final ReagentForm reagentForm;
  final int index;
  final VoidCallback onRemove;

  const ReagentWidget({
    super.key,
    required this.reagentForm,
    required this.index,
    required this.onRemove,
  });

  @override
  _ReagentWidgetState createState() => _ReagentWidgetState();
}

class _ReagentWidgetState extends State<ReagentWidget> {
  @override
  void initState() {
    super.initState();
    widget.reagentForm.nameController.addListener(_updateConcentrationLabel);
  }

  @override
  void dispose() {
    widget.reagentForm.nameController.removeListener(_updateConcentrationLabel);
    super.dispose();
  }

  void _updateConcentrationLabel() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String reagentName = widget.reagentForm.nameController.text.trim();
    String concentrationLabel = reagentName.isEmpty
        ? 'Concentration of Reagent'
        : 'Concentration of $reagentName';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.reagentForm.nameController,
          decoration: InputDecoration(
            labelText: 'Reagent #${widget.index + 1}',
            border: OutlineInputBorder(),
          ),
          maxLength: 100,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Reagent is required';
            }
            return null;
          },
        ),
        SizedBox(height: 8.0),
        TextFormField(
          controller: widget.reagentForm.concentrationController,
          decoration: InputDecoration(
            labelText: concentrationLabel,
            border: OutlineInputBorder(),
          ),
          maxLength: 100,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Concentration is required';
            }
            return null;
          },
        ),
        SizedBox(height: 8.0),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: widget.onRemove,
            icon: Icon(Icons.remove_circle, color: Colors.red),
            label: Text(
              'Remove Reagent',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}
