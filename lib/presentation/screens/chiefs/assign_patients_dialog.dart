import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AssignPatientsDialog extends StatefulWidget {
  final int employeeId;
  final String userType;
  final String serviceName;
  final String clues;

  const AssignPatientsDialog({
    super.key,
    required this.employeeId,
    required this.userType,
    required this.serviceName,
    required this.clues,
  });

  @override
  State<AssignPatientsDialog> createState() => _AssignPatientsDialogState();
}

class _AssignPatientsDialogState extends State<AssignPatientsDialog> {
  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> filteredPatients = [];
  List<int> selectedPatients = [];
  List<int> deselectedPatients = [];
  List<Map<String, dynamic>> reassignmentQueue = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    setState(() => isLoading = true);
    final url = Uri.parse(
        '$baseUrl/assign_tasks/patients/${widget.serviceName}?clues=${widget.clues}&employeeId=${widget.employeeId}&userType=${widget.userType}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          patients = data
              .map((item) => {
                    'id': int.parse(item['id'].toString()),
                    'name': item['name'],
                    'bed_number': item['bed_number'],
                    'related_to_employee': item['related_to_employee'],
                    'currentEmployeeId': item['currentEmployeeId'] != null
                        ? int.tryParse(item['currentEmployeeId'].toString())
                        : null,
                    'currentPersonalId': item['currentPersonalId'] != null
                        ? int.tryParse(item['currentPersonalId'].toString())
                        : null,
                  })
              .toList();
          filteredPatients = List.from(patients);
          selectedPatients = patients
              .where((patient) =>
                  patient['related_to_employee'] == 'assigned_to_this')
              .map((patient) => patient['id'] as int)
              .toList();
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading patients'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading patients'.tr())),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void filterPatients(String query) {
    setState(() {
      filteredPatients = patients
          .where((patient) => patient['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: filterPatients,
              decoration: InputDecoration(
                labelText: "Search Patients".tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.circle, color: Colors.orange, size: 12),
                      const SizedBox(width: 8),
                      Text("Yellow: Assigned to another personal".tr(),
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.circle, color: Colors.green, size: 12),
                      const SizedBox(width: 8),
                      Text("Green: Assigned to current personal".tr(),
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.circle, color: Colors.black, size: 12),
                      const SizedBox(width: 8),
                      Text("Black: Unassigned".tr(),
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, index) {
                        final patient = filteredPatients[index];
                        final relatedStatus = patient['related_to_employee'];

                        return CheckboxListTile(
                          title: Text(
                            "Cama:".tr(args: [
                              patient['name'],
                              patient['bed_number'].toString()
                            ]),
                            style: TextStyle(
                              color: relatedStatus == 'assigned_to_other'
                                  ? Colors.orange
                                  : relatedStatus == 'assigned_to_this'
                                      ? Colors.green
                                      : Colors.black,
                              fontStyle: relatedStatus == 'unassigned'
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                          value: selectedPatients.contains(patient['id']),
                          onChanged: (isSelected) {
                            setState(() {
                              if (relatedStatus == 'assigned_to_other') {
                                if (isSelected == true) {
                                  reassignmentQueue.add({
                                    'patientId': patient['id'],
                                    'currentPersonalId':
                                        patient['currentPersonalId']
                                  });
                                  selectedPatients.add(patient['id']);
                                } else {
                                  reassignmentQueue.removeWhere((item) =>
                                      item['patientId'] == patient['id']);
                                  selectedPatients.remove(patient['id']);
                                }
                              } else {
                                if (isSelected == true) {
                                  selectedPatients.add(patient['id']);
                                  deselectedPatients.remove(patient['id']);
                                } else {
                                  selectedPatients.remove(patient['id']);
                                  if (relatedStatus == 'assigned_to_this') {
                                    deselectedPatients.add(patient['id']);
                                  }
                                }
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'.tr()),
                ),
                TextButton(
                  onPressed: () async {
                    await applyChanges();
                    _navigator();
                  },
                  child: Text('Assign'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> applyChanges() async {
    for (final reassignment in reassignmentQueue) {
      await reassignPatient(
          reassignment['patientId'], reassignment['currentPersonalId']);
    }
  }

  Future<void> reassignPatient(int patientId, int currentPersonalId) async {
    final url = Uri.parse('$baseUrl/assign_tasks/reassign_patient');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patientId': patientId,
          'currentEmployeeId': currentPersonalId,
          'newEmployeeId': widget.employeeId,
          'userType': widget.userType,
        }),
      );

      if (response.statusCode != 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reassigning patient'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reassigning patient'.tr())),
        );
      }
    }
  }

  void _navigator() {
    if (mounted) {
      Navigator.pop(context, {
        'selected': selectedPatients,
        'deselected': deselectedPatients,
      });
    }
  }
}
