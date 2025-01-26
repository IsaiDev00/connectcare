import 'dart:async';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/user_service.dart';
import 'package:easy_localization/easy_localization.dart';
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

  // Variables para BPM
  int? bpm;
  bool isInitialBpmLoading = true; // Indicador para carga inicial
  Timer? bpmTimer;

  @override
  void initState() {
    super.initState();
    _fetchLinkedPatients();
  }

  @override
  void dispose() {
    bpmTimer?.cancel(); // Cancelar el Timer al destruir el widget
    super.dispose();
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

        if (selectedPatient != null) {
          final nss = selectedPatient!['nss'];
          _fetchBpmData(nss, isInitialFetch: true);

          // Iniciar el Timer para actualizar BPM cada 5 minutos
          bpmTimer = Timer.periodic(Duration(minutes: 2), (timer) {
            _fetchBpmData(nss);
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch patients'.tr())),
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching patients'.tr())),
        );
      }
    }
  }

  Future<void> _fetchBpmData(int? nss, {bool isInitialFetch = false}) async {
    if (nss == null) {
      setState(() {
        bpm = null;
        if (isInitialFetch) {
          isInitialBpmLoading = false;
        }
      });
      return;
    }

    if (isInitialFetch) {
      setState(() {
        isInitialBpmLoading = true;
      });
    }

    final url = Uri.parse('$baseUrl/samm/lpm/$nss');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          bpm = int.tryParse(data['lpm']?.toString() ?? '0');
          if (isInitialFetch) {
            isInitialBpmLoading = false;
          }
        });
      } else {
        if (isInitialFetch) {
          setState(() {
            isInitialBpmLoading = false;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener BPM.'.tr())),
        );
      }
    } catch (e) {
      if (isInitialFetch) {
        setState(() {
          isInitialBpmLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener BPM.'.tr())),
      );
    }
  }

  Widget _buildBpmWidget() {
    if (isInitialBpmLoading) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Corazón
              Icon(
                Icons.favorite,
                color: Colors.red,
                size: 50,
              ),
              SizedBox(width: 20),
              // Indicador de carga inicial
              Text(
                'Cargando BPM...'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Corazón
            Icon(
              Icons.favorite,
              color: Colors.red,
              size: 50,
            ),
            SizedBox(width: 20),
            // BPM
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latidos Por Minuto'.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                bpm == null
                    ? Text(
                        'Sensor no colocado'.tr(),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      )
                    : Text(
                        '$bpm LPM',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
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
    final nss = patient['nss'];

    // Iniciar la obtención de BPM y configurar el Timer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBpmData(nss, isInitialFetch: bpm == null);

      // Cancelar cualquier Timer existente
      bpmTimer?.cancel();

      // Configurar el Timer para actualizar BPM cada 5 minutos
      bpmTimer = Timer.periodic(Duration(minutes: 5), (timer) {
        _fetchBpmData(nss);
      });
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Widget de BPM
        _buildBpmWidget(),

        _buildSection(
            'General Information'.tr(),
            [
              ListTile(
                leading: Icon(Icons.person,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text(
                    'Name:'.tr(args: [patient['nombre_paciente'] ?? 'N/A']),
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              ListTile(
                leading: Icon(Icons.credit_card,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text('NSS:'.tr(args: [patient['nss'].toString()]),
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              ListTile(
                leading: Icon(Icons.medical_services,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text(
                    'Doctor:'.tr(args: [patient['medico_nombre'] ?? 'N/A']),
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              ListTile(
                leading: Icon(Icons.local_hospital,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text(
                    'Nurse:'.tr(args: [patient['enfermero_nombre'] ?? 'N/A']),
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              ListTile(
                leading: Icon(Icons.health_and_safety,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text('Status:'.tr(args: [patient['estado'] ?? 'N/A']),
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              ListTile(
                leading: Icon(Icons.meeting_room,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text(
                    'Room:'.tr(args: [
                      patient['sala_nombre'],
                      (patient['sala_numero'])
                    ]),
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              ListTile(
                leading: Icon(Icons.bed,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text(
                    'Bed:'.tr(args: [patient['numero_cama'].toString()]),
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              ListTile(
                leading: Icon(Icons.calendar_today,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text(
                    'Days Admitted:'
                        .tr(args: [patient['dias_interno'].toString()]),
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              ListTile(
                leading: Icon(Icons.access_time,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text(
                    'Visit Hours:'.tr(args: [
                      patient['horario_visita_inicio'],
                      patient['horario_visita_fin']
                    ]),
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
                title: Text(
                    'Diagnosis: {}'.tr(args: [patient['diagnostico'] ?? 'N/A']),
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
                    'Current Procedure:'
                        .tr(args: [patient['procedimiento_actual'] ?? 'N/A']),
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
                  title: Text(
                      'Nutrition.:'.tr(args: [patient['nutricion'] ?? 'N/A']),
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                ListTile(
                  leading: Icon(Icons.medication,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text(
                      'Medications.:'
                          .tr(args: [patient['medicamentos'] ?? 'N/A']),
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
                  title: Text('Notes:'.tr(args: [patient['nota'] ?? 'N/A']),
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                ListTile(
                  leading: Icon(Icons.trending_up,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text(
                      'Prognosis:'.tr(args: [patient['pronostico'] ?? 'N/A']),
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                ListTile(
                  leading: Icon(Icons.timeline,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text(
                      'Evolution:'.tr(args: [patient['evolucion'] ?? 'N/A']),
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text(
                      'Discharge Plan:'
                          .tr(args: [patient['plan_egreso'] ?? 'N/A']),
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                ListTile(
                  leading: Icon(Icons.search,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text(
                      'Physical Exam:'
                          .tr(args: [patient['exploracion_fisica'] ?? 'N/A']),
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                ListTile(
                  leading: Icon(Icons.image,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text('Image:'.tr(args: [patient['imagen'] ?? 'N/A']),
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
              ],
              context),
        if (relationship == 'main')
          _buildSection(
            'Requested Medications'.tr(),
            (patient['medicamentos_solicitados'] as List<dynamic>)
                .map((med) => ListTile(
                      leading: Icon(Icons.local_pharmacy,
                          color: Theme.of(context).colorScheme.secondary),
                      title: Text(
                          'Medication:'
                              .tr(args: [med['nombre_reactivo'], med['marca']]),
                          style: Theme.of(context).textTheme.headlineSmall),
                      subtitle: Text(
                          'Concentration.:'.tr(args: [
                            med['concentracion'],
                            med['via_administracion'],
                            med['cantidad'].toString(),
                            med['unidad'].toString()
                          ]),
                          style: Theme.of(context).textTheme.bodyLarge),
                    ))
                .toList(),
            context,
          ),
        if (relationship == 'occasional')
          _buildSection(
              'Evolution Notes'.tr(),
              [
                ListTile(
                  leading: Icon(Icons.timeline,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text(
                      'Evolution:'.tr(args: [patient['evolucion'] ?? 'N/A']),
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
              ],
              context),
        if (relationship == 'regular')
          _buildSection(
              'Evolution Notes'.tr(),
              [
                ListTile(
                  leading: Icon(Icons.timeline,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text(
                      'Evolution:'.tr(args: [patient['evolucion'] ?? 'N/A']),
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                ListTile(
                  leading: Icon(Icons.image,
                      color: Theme.of(context).colorScheme.secondary),
                  title: Text('Image:'.tr(args: [patient['imagen'] ?? 'N/A']),
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
        title: Text('Home Screen'.tr()),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : patients.isEmpty
              ? Center(child: Text('No linked patients found.'.tr()))
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
                            bpm = null; // Resetear BPM
                            isInitialBpmLoading = true; // Indicar carga inicial
                            bpmTimer?.cancel(); // Cancelar el Timer anterior
                          });
                          if (value != null) {
                            final nss = value['nss'];
                            _fetchBpmData(nss, isInitialFetch: true);

                            // Iniciar el Timer para actualizar BPM cada 5 minutos
                            bpmTimer =
                                Timer.periodic(Duration(minutes: 5), (timer) {
                              _fetchBpmData(nss);
                            });
                          }
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
