import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FamilyMemberHomeScreen extends StatefulWidget {
  const FamilyMemberHomeScreen({super.key});

  @override
  FamilyMemberHomeScreenState createState() => FamilyMemberHomeScreenState();
}

class FamilyMemberHomeScreenState extends State<FamilyMemberHomeScreen> {
  List<dynamic> patients = [];
  Map<String, dynamic>? selectedPatient;
  bool isLoading = true;
  final UserService _userService = UserService();
  String id = '';

  @override
  void initState() {
    super.initState();
    _fetchLinkedPatients();
  }

  Future<void> _fetchLinkedPatients() async {
    final data = await _userService.loadUserData();
    setState(() {
      id = (data['userId'] ?? '');
      isLoading = true;
    });
    final url = Uri.parse('$baseUrl/family_link/linked-patients/details/$id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          patients = json.decode(response.body);
          selectedPatient = patients.isNotEmpty ? patients[0] : null;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to fetch patients: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching patients: $e')),
      );
    }
  }

  Widget _buildSection(
      String title, List<Widget> content, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _buildPatientDetails(
      Map<String, dynamic> patient, BuildContext context) {
    final relationship = patient['relacion'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSection(
            'General Information',
            [
              ListTile(
                leading: Icon(Icons.person,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text('Name: ${patient['nombre_paciente']}',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              ListTile(
                leading: Icon(Icons.credit_card,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text('NSS: ${patient['nss']}',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              ListTile(
                leading: Icon(Icons.medical_services,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text('Doctor: ${patient['medico_nombre'] ?? 'N/A'}',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              ListTile(
                leading: Icon(Icons.local_hospital,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text('Nurse: ${patient['enfermero_nombre'] ?? 'N/A'}',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              ListTile(
                leading: Icon(Icons.health_and_safety,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text('Status: ${patient['estado'] ?? 'N/A'}',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              ListTile(
                leading: Icon(Icons.meeting_room,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text(
                    'Room: ${patient['sala_nombre']} (${patient['sala_numero']})',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              ListTile(
                leading: Icon(Icons.bed,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text('Bed: ${patient['numero_cama']}',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              ListTile(
                leading: Icon(Icons.calendar_today,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text('Days Admitted: ${patient['dias_interno']}',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              ListTile(
                leading: Icon(Icons.access_time,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text(
                    'Visit Hours: ${patient['horario_visita_inicio']} - ${patient['horario_visita_fin']}',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
            ],
            context),
        _buildSection(
            'Diagnosis',
            [
              ListTile(
                leading: Icon(Icons.assignment,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text('Diagnosis: ${patient['diagnostico'] ?? 'N/A'}',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
            ],
            context),
        _buildSection(
            'Procedures',
            [
              ListTile(
                leading: Icon(Icons.build,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text(
                    'Current Procedure: ${patient['procedimiento_actual'] ?? 'N/A'}',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
            ],
            context),
        if (relationship == 'main')
          _buildSection(
              'Medical Indications',
              [
                ListTile(
                  leading: Icon(Icons.restaurant,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text('Nutrition: ${patient['nutricion'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                ListTile(
                  leading: Icon(Icons.medication,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text(
                      'Medications: ${patient['medicamentos'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
              ],
              context),
        if (relationship == 'main')
          _buildSection(
              'Evolution Notes',
              [
                ListTile(
                  leading: Icon(Icons.note,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text('Notes: ${patient['nota'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                ListTile(
                  leading: Icon(Icons.trending_up,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text('Prognosis: ${patient['pronostico'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                ListTile(
                  leading: Icon(Icons.timeline,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text('Evolution: ${patient['evolucion'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text(
                      'Discharge Plan: ${patient['plan_egreso'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                ListTile(
                  leading: Icon(Icons.search,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text(
                      'Physical Exam: ${patient['exploracion_fisica'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                ListTile(
                  leading: Icon(Icons.image,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text('Image: ${patient['imagen'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
              ],
              context),
        if (relationship == 'main')
          _buildSection(
            'Requested Medications',
            (patient['medicamentos_solicitados'] as List<dynamic>)
                .map((med) => ListTile(
                      leading: Icon(Icons.local_pharmacy,
                          color: Theme.of(context).colorScheme.secondary),
                      title: Text(
                          'Medication: ${med['nombre_reactivo']} (${med['marca']})',
                          style: Theme.of(context).textTheme.headlineSmall),
                      subtitle: Text(
                          'Concentration: ${med['concentracion']} | Administration: ${med['via_administracion']} | Amount: ${med['cantidad']} ${med['unidad']}',
                          style: Theme.of(context).textTheme.bodyLarge),
                    ))
                .toList(),
            context,
          ),
        if (relationship == 'occasional')
          _buildSection(
              'Evolution Notes',
              [
                ListTile(
                  leading: Icon(Icons.timeline,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text('Evolution: ${patient['evolucion'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
              ],
              context),
        if (relationship == 'regular')
          _buildSection(
              'Evolution Notes',
              [
                ListTile(
                  leading: Icon(Icons.timeline,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text('Evolution: ${patient['evolucion'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                ListTile(
                  leading: Icon(Icons.image,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text('Image: ${patient['imagen'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
              ],
              context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Member Home'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : patients.isEmpty
              ? const Center(child: Text('No linked patients found.'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButtonFormField<dynamic>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        isExpanded: true,
                        value: selectedPatient,
                        items: patients
                            .map((patient) => DropdownMenuItem(
                                  value: patient,
                                  child: Text(patient['nombre_paciente'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPatient = value;
                          });
                        },
                      ),
                    ),
                    if (selectedPatient != null)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child:
                                _buildPatientDetails(selectedPatient!, context),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
