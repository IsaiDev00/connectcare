import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/presentation/screens/chiefs/assign_patients_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AssignTasksScreen extends StatefulWidget {
  const AssignTasksScreen({
    super.key,
  });

  @override
  State<AssignTasksScreen> createState() => _AssignTasksScreenState();
}

class _AssignTasksScreenState extends State<AssignTasksScreen> {
  String userType = '';
  String services = '';
  String clues = '';
  final UserService _userService = UserService();
  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> filteredEmployees = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await _userService.loadUserData();
    setState(() {
      userType = (data['userType'] ?? '');
      services = (data['services'] ?? '');
      clues = (data['clues'] ?? '');
    });

    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    final url = Uri.parse(
        '$baseUrl/assign_tasks/staff/$userType/$services?clues=$clues');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) {
          _noEmployeesFound();
        } else {
          setState(() {
            employees = data
                .map((item) => {
                      'id': int.parse(item['id'].toString()),
                      'name': item['name'] ?? 'Unknown',
                      'role': _translateRole(item['role'] ?? 'Unknown'),
                    })
                .toList();

            employees.sort((a, b) => a['role'] == 'chief' ? -1 : 1);

            filteredEmployees = List.from(employees);
          });
        }
      } else {
        _errorLoadingEmployees();
      }
    } catch (e) {
      _errorLoadingEmployees();
    }
  }

  void filterEmployees(String query) {
    setState(() {
      filteredEmployees = employees
          .where((employee) =>
              employee['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  String _translateRole(String role) {
    switch (role) {
      case 'chief':
        return 'chief_role'.tr();
      case 'member':
        return 'member_role'.tr();
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Assign Tasks".tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: filterEmployees,
              decoration: InputDecoration(
                labelText: "search_employee".tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
                child: filteredEmployees.isEmpty
                    ? Center(child: Text("No employees found".tr()))
                    : ListView.builder(
                        itemCount: filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final employee = filteredEmployees[index];
                          return ListTile(
                            title: Text(
                              employee['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            subtitle: Text("Role".tr(args: [employee['role']])),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () async {
                              final result =
                                  await showDialog<Map<String, List<int>>>(
                                context: context,
                                builder: (context) => AssignPatientsDialog(
                                  employeeId: employee['id'],
                                  userType: userType,
                                  serviceName: services,
                                  clues: clues,
                                ),
                              );

                              if (result != null) {
                                final selectedPatients =
                                    result['selected'] ?? [];
                                final deselectedPatients =
                                    result['deselected'] ?? [];

                                final url = Uri.parse(
                                    '$baseUrl/assign_tasks/link_unlink_patients');
                                try {
                                  final response = await http.post(
                                    url,
                                    headers: {
                                      'Content-Type': 'application/json'
                                    },
                                    body: jsonEncode({
                                      'employeeId': employee['id'],
                                      'userType': userType,
                                      'selectedPatients': selectedPatients,
                                      'deselectedPatients': deselectedPatients,
                                    }),
                                  );

                                  if (response.statusCode == 200) {
                                    _patientsUpdatedSuccesfully();
                                  } else {
                                    _errorUpdatingPatients();
                                  }
                                } catch (e) {
                                  _errorUpdatingPatients();
                                }
                              }
                            },
                          );
                        },
                      )),
          ],
        ),
      ),
    );
  }

  void _patientsUpdatedSuccesfully() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Patients updated successfully'.tr())),
    );
  }

  void _errorUpdatingPatients() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error updating patients'.tr())),
    );
  }

  void _errorLoadingEmployees() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading employees'.tr())),
    );
  }

  void _noEmployeesFound() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No employees found'.tr())),
    );
  }
}
