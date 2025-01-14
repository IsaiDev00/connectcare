import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/presentation/screens/doctor/documents.dart/hoja_enfermeria_screen.dart';
import 'package:connectcare/presentation/screens/doctor/medical_instructions.dart';
import 'package:connectcare/presentation/screens/doctor/patient_history.dart';
import 'package:connectcare/presentation/screens/doctor/progress_note.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  DoctorHomeScreenState createState() => DoctorHomeScreenState();
}

class DoctorHomeScreenState extends State<DoctorHomeScreen> {
  String? doctorId;
  List<Map<String, dynamic>> patients = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _initEverything();
  }

  Future<void> _initEverything() async {
    await _loadDoctorData();
    await _updateTokenIfUserLogged();
  }

  Future<void> _loadDoctorData() async {
    final userData = await UserService().loadUserData();
    setState(() {
      doctorId = userData['userId'];
    });
    if (doctorId != null) {
      await _fetchPatients();
    }
  }
  Future<void> _updateTokenIfUserLogged() async {
    if (doctorId == null || doctorId!.isEmpty) {
      print("No se puede actualizar token. El doctorId es nulo o está vacío.");
      return;
    }

    final userService = UserService();
    await userService.updateFirebaseTokenAndSendNotification();
  }

  /// Obtiene la lista de pacientes del backend, usando el doctorId.
  Future<void> _fetchPatients() async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse('$baseUrl/assign_tasks/doctor/patients/$doctorId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          patients = data
              .map((item) => {
                    'id': item['id'],
                    'name': item['name'],
                    'bed_number': item['bed_number'],
                    'age': item['age'],
                  })
              .toList();
          filteredPatients = List.from(patients);
        });
      } else {
        _errorFetchingPatients();
      }
    } catch (e) {
      _errorFetchingPatients();
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _filterPatients(String query) {
    setState(() {
      filteredPatients = patients
          .where((patient) =>
              patient['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showPatientOptionsDialog(
      BuildContext context, Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Options for".tr(args: [patient['name']]),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.medical_services,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  "Nursing Sheet".tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () {
                  print("nss: ${patient['id']}");
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HojaEnfermeriaScreen(nssPaciente: patient['id'].toString()),
                    ),
                  );
                },
              ),
              Divider(color: Theme.of(context).dividerColor),
              ListTile(
                leading: Icon(
                  Icons.notes,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  "Medical Instructions Sheet".tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicalInstructions(),
                    ),
                  );
                },
              ),
              Divider(color: Theme.of(context).dividerColor),
              ListTile(
                leading: Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  "Patient History".tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientHistory(),
                    ),
                  );
                },
              ),
              Divider(color: Theme.of(context).dividerColor),
              ListTile(
                leading: Icon(
                  Icons.note,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  "Evolution Note".tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProgressNote(),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel".tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: _filterPatients,
              decoration: InputDecoration(
                labelText: "Search Patients".tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: filteredPatients.isEmpty
                        ? Center(child: Text("No patients assigned".tr()))
                        : ListView.builder(
                            itemCount: filteredPatients.length,
                            itemBuilder: (context, index) {
                              final patient = filteredPatients[index];
                              return ListTile(
                                title: Text(patient['name']),
                                subtitle: Text("info_patient".tr(args: [
                                  patient['bed_number'].toString(),
                                  patient['age'].toString(),
                                  patient['id'].toString()
                                ])),
                                onTap: () {
                                  _showPatientOptionsDialog(context, patient);
                                },
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }

  void _errorFetchingPatients() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching patients'.tr())),
      );
    }
  }
}
