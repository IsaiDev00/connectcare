import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/presentation/screens/doctor/documents.dart/hoja_enfermeria_screen.dart';
import 'package:connectcare/presentation/screens/nurse/medical_instructions_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NurseHomeScreen extends StatefulWidget {
  const NurseHomeScreen({super.key});

  @override
  NurseHomeScreenState createState() => NurseHomeScreenState();
}

class NurseHomeScreenState extends State<NurseHomeScreen> {
  String? nurseId;
  List<Map<String, dynamic>> patients = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _loadNurseData();
  }

  Future<void> _loadNurseData() async {
    final userData = await UserService().loadUserData();
    setState(() {
      nurseId = userData['userId'];
    });
    if (nurseId != null) {
      await _fetchPatients();
    }
  }

  Future<void> _fetchPatients() async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse('$baseUrl/assign_tasks/nurse/patients/$nurseId');
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
      setState(() {
        isLoading = false;
      });
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
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HojaEnfermeriaScreen(
                          nssPaciente: patient['id'].toString()),
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
                      builder: (context) => MedicalInstructionsScreen(
                          nssPaciente: patient['id'].toString(),
                          patientName: patient['name']),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching patients'.tr())),
    );
  }
}
