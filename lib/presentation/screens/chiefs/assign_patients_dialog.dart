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
  List<int> selectedPatients = [];
  List<int> deselectedPatients = [];
  bool isLoading = true;

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
                  })
              .toList();
          selectedPatients = patients
              .where((patient) => patient['related_to_employee'] == 1)
              .map((patient) => patient['id'] as int)
              .toList();
        });
      } else {
        _errorLoadingPatients();
      }
    } catch (e) {
      _errorLoadingPatients();
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: patients.length,
                      itemBuilder: (context, index) {
                        final patient = patients[index];
                        final relatedStatus = patient['related_to_employee'];

                        return CheckboxListTile(
                          title: Text(
                            "Cama:".tr(args: [
                              patient['name'],
                              patient['bed_number'].toString()
                            ]),
                            style: TextStyle(
                              color: relatedStatus == 0
                                  ? Colors.grey
                                  : Colors.black,
                              fontStyle: relatedStatus == 0
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                          value: selectedPatients.contains(patient['id']),
                          onChanged: relatedStatus == 0
                              ? null
                              : (isSelected) {
                                  setState(() {
                                    if (isSelected == true) {
                                      selectedPatients.add(patient['id']);
                                      deselectedPatients.remove(patient['id']);
                                    } else {
                                      selectedPatients.remove(patient['id']);
                                      if (relatedStatus == 1) {
                                        deselectedPatients.add(patient['id']);
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
                  onPressed: () => Navigator.pop(context, {
                    'selected': selectedPatients,
                    'deselected': deselectedPatients,
                  }),
                  child: Text('Assign'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _errorLoadingPatients() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading patients'.tr())),
    );
  }
}
