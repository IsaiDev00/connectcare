import 'dart:async';
import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MedicalInstructions extends StatefulWidget {
  final String nssPaciente;
  final String patientName;
  final String services;

  const MedicalInstructions({
    super.key,
    required this.nssPaciente,
    required this.services,
    required this.patientName,
  });

  @override
  MedicalInstructionsState createState() => MedicalInstructionsState();
}

class MedicalInstructionsState extends State<MedicalInstructions> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {
    'diagnostico': TextEditingController(),
    'peso': TextEditingController(),
    'ret': TextEditingController(),
    'lntp': TextEditingController(),
    'lve': TextEditingController(),
    'formula': TextEditingController(),
    'nutricion': TextEditingController(),
    'soluciones': TextEditingController(),
    'medicamentos': TextEditingController(),
    'medidas_generales': TextEditingController(),
    'cuidados_cvc': TextEditingController(),
    'pendientes': TextEditingController(),
  };

  late String _currentDateTime;
  late Timer _timer;
  bool usoSamm = false;

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
    _loadLastSammValue();
  }

  Future<void> _loadLastSammValue() async {
    final url = Uri.parse(
        '$baseUrl/indicaciones_medicas/uso_samm/${widget.nssPaciente}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            usoSamm = data['uso_samm'] == 1;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Error fetching SAMM status: ${response.statusCode}'.tr())),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        //print("error: $e");
      }
    }
  }

  Future<void> _submitInstructions() async {
    if (_formKey.currentState?.validate() ?? false) {
      final url = Uri.parse('$baseUrl/indicaciones_medicas');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'nss_paciente': widget.nssPaciente,
            ...controllers
                .map((key, controller) => MapEntry(key, controller.text)),
            'uso_samm': usoSamm,
          }),
        );

        if (response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Medical instructions saved successfully'.tr())),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving medical instructions'.tr())),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medical Instructions".tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPatientInfo(),
              _buildDivider(),
              _buildSectionTitle('Vital Data', Icons.monitor_heart),
              _buildFields([
                {'field': 'peso', 'icon': Icons.monitor_weight},
                {'field': 'ret', 'icon': Icons.timeline},
                {'field': 'lntp', 'icon': Icons.bloodtype},
                {'field': 'lve', 'icon': Icons.battery_alert},
              ]),
              _buildDivider(),
              _buildSectionTitle(
                  'Treatment and Formulas', Icons.local_hospital),
              _buildFields([
                {'field': 'diagnostico', 'icon': Icons.medical_services},
                {'field': 'formula', 'icon': Icons.local_drink},
                {'field': 'nutricion', 'icon': Icons.food_bank},
                {'field': 'soluciones', 'icon': Icons.local_hospital},
              ]),
              _buildDivider(),
              _buildSectionTitle('Care and Observations', Icons.notes),
              _buildFields([
                {'field': 'medicamentos', 'icon': Icons.healing},
                {'field': 'medidas_generales', 'icon': Icons.settings},
                {'field': 'cuidados_cvc', 'icon': Icons.local_pharmacy},
                {'field': 'pendientes', 'icon': Icons.pending_actions},
              ]),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    width: 1.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: usoSamm,
                        onChanged: (bool? newValue) {
                          setState(() {
                            usoSamm = newValue ?? false;
                          });
                        },
                        activeColor: Colors.teal,
                        checkColor: Colors.white,
                      ),
                      const SizedBox(width: 1.0),
                      Flexible(
                        child: Text(
                          'Uso de SAMM'.tr(),
                          style: const TextStyle(
                            fontSize: 11.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitInstructions,
                child: Text('Save Instructions'.tr()),
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

  Widget _buildFields(List<Map<String, dynamic>> fields) {
    return Column(
      children: fields
          .map((item) => _buildTextField(item['field'], item['icon']))
          .toList(),
    );
  }

  Widget _buildTextField(String fieldName, IconData icon) {
    const fieldsWithCounter = [
      'diagnostico',
      'formula',
      'nutricion',
      'medicamentos',
      'medidas_generales',
      'cuidados_cvc',
      'pendientes',
      'soluciones'
    ];

    const numericFields = ['peso', 'ret', 'lntp', 'lve'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controllers[fieldName],
        maxLength: fieldsWithCounter.contains(fieldName) ? 500 : null,
        keyboardType: numericFields.contains(fieldName)
            ? TextInputType.number
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: fieldName.tr(),
          prefixIcon: Icon(icon, color: Colors.blueGrey),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if ((value ?? '').isEmpty) {
            return 'Field is required.'.tr();
          }
          if (fieldsWithCounter.contains(fieldName) &&
              (value?.length ?? 0) > 500) {
            return 'This field cannot exceed 500 characters.'.tr();
          }
          if (numericFields.contains(fieldName) &&
              !RegExp(r'^\d+(\.\d+)?$').hasMatch(value ?? '')) {
            return 'Only numeric values are allowed.'.tr();
          }
          return null;
        },
      ),
    );
  }
}
