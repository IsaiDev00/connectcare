import 'dart:async';
import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/presentation/widgets/selectable_calendar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectcare/presentation/screens/doctor/documents.dart/triage_screen.dart';

class ProgressNote extends StatefulWidget {
  final String nssPaciente;
  final String patientName;
  final String services;

  const ProgressNote({
    super.key,
    required this.nssPaciente,
    required this.services,
    required this.patientName,
  });

  @override
  ProgressNoteState createState() => ProgressNoteState();
}

class ProgressNoteState extends State<ProgressNote> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {
    'ta_sistolica': TextEditingController(),
    'ta_diastolica': TextEditingController(),
    'frecuencia_cardiaca': TextEditingController(),
    'frecuencia_respiratoria': TextEditingController(),
    'temperatura': TextEditingController(),
    'saturacion_oxigeno': TextEditingController(),
    'infeccion_nosocomial': TextEditingController(),
    'resultado_cultivo': TextEditingController(),
    'nota_medica': TextEditingController(),
    'evolucion_actual': TextEditingController(),
    'somatometria': TextEditingController(),
    'exploracion_fisica': TextEditingController(),
    'laboratorio': TextEditingController(),
    'imagen': TextEditingController(),
    'plan_y_comentario': TextEditingController(),
    'diagnostico': TextEditingController(),
    'pronostico': TextEditingController(),
  };

  final optionalFields = [
    'fecha_intubacion',
    'fecha_cateter',
    'infeccion_nosocomial',
    'fecha_solicitud_cultivo',
    'resultado_cultivo',
  ];

  late String _currentDateTime;
  late Timer _timer;
  DateTime? fechaIntubacion;
  DateTime? fechaCateter;
  DateTime? fechaSolicitudCultivo;
  List<Medication> medications = [];

  void _requestMedication() {
    showDialog(
      context: context,
      builder: (context) {
        return MedicationDialog(
          onSave: (Medication medication) {
            setState(() {
              medications.add(medication);
            });
          },
        );
      },
    );
  }

  Future<void> _registerMedications() async {
    for (int index = 0; index < medications.length; index++) {
      final medication = medications[index];
      final nssPaciente = widget.nssPaciente;

      if (medication.reagents.isEmpty ||
          medication.quantity <= 0 ||
          medication.brand.isEmpty ||
          medication.route.isEmpty ||
          medication.type.isEmpty) {
        continue;
      }

      Map<String, dynamic> medicationData = {
        'nss_paciente': nssPaciente,
        'nombre_reactivo': medication.reagents.map((r) => r.name).toList(),
        'concentracion':
            medication.reagents.map((r) => r.concentration).toList(),
        'cantidad': medication.quantity,
        'marca': medication.brand,
        'via_administracion': medication.route,
        'unidad': medication.type,
        'fuente_tipo': 'progress_note',
      };

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/solicitud_medicamento/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(medicationData),
        );

        if (response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Medication request created successfully.'.tr()),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error requesting medication".tr())));
        }
      } catch (e) {
        //print('Error requesitng medication: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _currentDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentDateTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      });
    });
  }

  Future<void> _selectDate(String fieldName) async {
    final response = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectableCalendar(),
      ),
    );

    if (response != null && response['selectedDate'] != null) {
      final selectedDate = response['selectedDate'] as DateTime;
      setState(() {
        switch (fieldName) {
          case 'fecha_intubacion':
            fechaIntubacion = selectedDate;
            break;
          case 'fecha_cateter':
            fechaCateter = selectedDate;
            break;
          case 'fecha_solicitud_cultivo':
            fechaSolicitudCultivo = selectedDate;
            break;
        }
      });
    }
  }

  Future<void> _submitProgressNote() async {
    if (_formKey.currentState?.validate() ?? false) {
      final url = Uri.parse('$baseUrl/nota_de_evolucion');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'nss_paciente': widget.nssPaciente,
            ...controllers
                .map((key, controller) => MapEntry(key, controller.text)),
            'fecha_intubacion': fechaIntubacion != null
                ? DateFormat('yyyy-MM-dd').format(fechaIntubacion!)
                : null,
            'fecha_cateter': fechaCateter != null
                ? DateFormat('yyyy-MM-dd').format(fechaCateter!)
                : null,
            'fecha_solicitud_cultivo': fechaSolicitudCultivo != null
                ? DateFormat('yyyy-MM-dd').format(fechaSolicitudCultivo!)
                : null,
          }),
        );
        await _registerMedications();

        if (response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Evolution Note saved successfully'.tr())),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving Evolution Note'.tr())),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error connecting to server'.tr())),
          );
        }
      }
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildMedicationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSectionTitle('Requested Medications', Icons.medication),
        medications.isEmpty
            ? Text(
                'No medications requested yet.'.tr(),
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: medications.length,
                itemBuilder: (context, index) {
                  final medication = medications[index];
                  return ListTile(
                    title: Text(medication.brand),
                    subtitle: Text("medicine_info".tr(args: [
                      medication.type,
                      medication.quantity.toString(),
                      medication.route
                    ])),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          medications.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _requestMedication,
          child: Text('Add Medication'.tr()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text("Evolution Note".tr()),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPatientInfo(),
              _buildSectionTitle('Vital Signs', Icons.monitor_heart),
              _buildFields([
                {'field': 'ta_sistolica', 'icon': Icons.speed},
                {'field': 'ta_diastolica', 'icon': Icons.favorite},
                {'field': 'frecuencia_cardiaca', 'icon': Icons.favorite_border},
                {'field': 'frecuencia_respiratoria', 'icon': Icons.air},
                {'field': 'temperatura', 'icon': Icons.thermostat},
                {'field': 'saturacion_oxigeno', 'icon': Icons.cloud},
              ]),
              _buildDivider(),
              _buildSectionTitle('Medical Procedures', Icons.medical_services),
              _buildDateButton('fecha_intubacion', fechaIntubacion,
                  'Select Intubation Date'),
              _buildDateButton(
                  'fecha_cateter', fechaCateter, 'Select Catheter Date'),
              _buildDateButton('fecha_solicitud_cultivo', fechaSolicitudCultivo,
                  'Select Culture Request Date'),
              _buildDivider(),
              _buildSectionTitle('Observations & Diagnosis', Icons.notes),
              _buildFields([
                {'field': 'infeccion_nosocomial', 'icon': Icons.bug_report},
                {'field': 'resultado_cultivo', 'icon': Icons.science},
                {'field': 'nota_medica', 'icon': Icons.edit_note},
                {'field': 'evolucion_actual', 'icon': Icons.timeline},
                {'field': 'somatometria', 'icon': Icons.accessibility},
                {'field': 'exploracion_fisica', 'icon': Icons.search},
                {'field': 'laboratorio', 'icon': Icons.analytics},
                {'field': 'imagen', 'icon': Icons.image},
                {'field': 'plan_y_comentario', 'icon': Icons.comment},
                {'field': 'diagnostico', 'icon': Icons.assignment},
                {'field': 'pronostico', 'icon': Icons.query_stats},
              ]),
              _buildDivider(),
              _buildMedicationsSection(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitProgressNote,
                child: Text('Save Note'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('NSS'.tr(args: [widget.nssPaciente])),
        Text('Patient'.tr(args: [widget.patientName])),
        Text('Service'.tr(args: [widget.services.tr()])),
        Text('Date/Time'.tr(args: [_currentDateTime])),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00A0A6)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      thickness: 1.5,
      color: Colors.blueGrey,
    );
  }

  Widget _buildDateButton(
      String fieldName, DateTime? selectedDate, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: OutlinedButton(
        onPressed: () => _selectDate(fieldName),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.event,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              selectedDate != null
                  ? DateFormat('dd/MM/yyyy').format(selectedDate)
                  : label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFields(List<Map<String, dynamic>> fields) {
    return Column(
      children: fields
          .map((item) => _buildTextField(item['field'], item['icon']))
          .toList(),
    );
  }

  Widget _buildTextField(String fieldName, IconData icon) {
    const fieldsWithCounter = [
      'infeccion_nosocomial',
      'resultado_cultivo',
      'nota_medica',
      'evolucion_actual',
      'somatometria',
      'exploracion_fisica',
      'laboratorio',
      'imagen',
      'plan_y_comentario',
      'diagnostico',
      'pronostico',
    ];

    const optionalFields = [
      'fecha_intubacion',
      'fecha_cateter',
      'infeccion_nosocomial',
      'fecha_solicitud_cultivo',
      'resultado_cultivo',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controllers[fieldName],
        maxLength: fieldsWithCounter.contains(fieldName) ? 500 : null,
        keyboardType: fieldName.startsWith('ta') ||
                fieldName.startsWith('frecuencia') ||
                fieldName == 'temperatura' ||
                fieldName == 'saturacion_oxigeno'
            ? TextInputType.number
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: fieldName.tr(),
          prefixIcon: Icon(icon, color: Colors.blueGrey),
          border: const OutlineInputBorder(),
          counterText: fieldsWithCounter.contains(fieldName) ? null : "",
        ),
        validator: (value) {
          if ((value ?? '').isEmpty && !optionalFields.contains(fieldName)) {
            return 'Field is required.'.tr();
          }
          if (fieldsWithCounter.contains(fieldName) &&
              (value?.length ?? 0) > 500) {
            return 'This field cannot exceed 500 characters.'.tr();
          }
          return null;
        },
      ),
    );
  }
}
