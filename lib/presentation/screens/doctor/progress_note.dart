import 'dart:async';
import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/presentation/widgets/selectable_calendar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProgressNote extends StatefulWidget {
  final String nssPaciente;
  final String patientName;
  final String services;

  const ProgressNote(
      {super.key,
      required this.nssPaciente,
      required this.services,
      required this.patientName});

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

  Widget _buildPatientInfo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NSS'.tr(args: [widget.nssPaciente]),
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            'Patient'.tr(args: [widget.patientName]),
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            'Service'.tr(args: [widget.services.tr()]),
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            'Date/Time'.tr(args: [_currentDateTime]),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _submitProgressNote() async {
    // Valida todos los campos.
    if (_formKey.currentState?.validate() ?? false) {
      // Si no hay problemas de validación, procede con el envío.
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
      // Si hay errores, asegúrate de que el formulario se redibuje para mostrar los errores.
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF00A0A6)),
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
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildPatientInfo(),
              _buildSectionTitle('Vital Signs', Icons.monitor_heart),
              ...[
                {'field': 'ta_sistolica', 'icon': Icons.speed},
                {'field': 'ta_diastolica', 'icon': Icons.favorite},
                {'field': 'frecuencia_cardiaca', 'icon': Icons.favorite_border},
                {'field': 'frecuencia_respiratoria', 'icon': Icons.air},
                {'field': 'temperatura', 'icon': Icons.thermostat},
                {'field': 'saturacion_oxigeno', 'icon': Icons.cloud},
              ].map((item) => _buildTextField(
                  item['field'] as String, item['icon'] as IconData)),
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
              ...[
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
              ].map((item) => _buildTextField(
                  item['field'] as String, item['icon'] as IconData)),
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
            return 'This field is required.'.tr();
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
