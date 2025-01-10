import 'dart:convert';

import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

class ManageShifts extends StatefulWidget {
  const ManageShifts({super.key});

  @override
  State<ManageShifts> createState() => _ManageShiftsState();
}

class _ManageShiftsState extends State<ManageShifts> {
  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> filteredEmployees = [];
  TextEditingController searchController = TextEditingController();
  final List<Map<String, String>> shifts = [
    {'key': 'morning', 'value': tr('Turno de la mañana: 7:00 a 15:00')},
    {'key': 'afternoon', 'value': tr('Turno de la tarde: 15:00 a 23:00')},
    {'key': 'night', 'value': tr('Turno de la noche: 23:00 a 7:00')},
    {'key': 'fulltime', 'value': tr('Turno completo: 00:00 a 00:00')},
  ];
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();
  String? selectedShift;
  String? _clues;

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    final data = await _sharedPreferencesService.getClues();
    setState(() {
      _clues = data ?? '';
    });
    if (_clues == null) {
      _cluesError();
      return;
    }

    final url = Uri.parse('$baseUrl/shifts/?clues=$_clues');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          employees = data
              .map((item) => {
                    'id': item['id'],
                    'name': item['name'],
                    'status': item['status'],
                    'schedule': item['schedule'],
                  })
              .toList();
          filteredEmployees = List.from(employees);
        });
      } else {
        throw Exception('Error fetching staff');
      }
    } catch (e) {
      _errorLoadingData();
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

  Future<void> updateShift(String employeeId, String shiftKey) async {
    final url = Uri.parse('$baseUrl/shifts/$employeeId/shift');
    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'schedule': shiftKey}),
      );
      if (response.statusCode == 200) {
        _shiftUpdateSuccessfully();
        fetchEmployees();
      } else {
        throw Exception('Error updating shift');
      }
    } catch (e) {
      _errorUpdatingShift();
    }
  }

  Future<void> deleteShift(String employeeId) async {
    final url = Uri.parse('$baseUrl/shifts/$employeeId/delete-shift');
    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'schedule': null, 'estatus': 'inactive'}),
      );
      if (response.statusCode == 200) {
        _shiftDelatedSuccessfully();
        fetchEmployees();
      } else {
        throw Exception('Error deleting shift');
      }
    } catch (e) {
      _errorDeletingShift();
    }
  }

  Future<void> toggleStatus(
      String employeeId, String? currentStatus, String? schedule) async {
    if (schedule == null || schedule.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('cannot_activate_no_schedule'))),
      );
      return;
    }

    final url = Uri.parse('$baseUrl/shifts/$employeeId/status');
    final newStatus = (currentStatus == null || currentStatus == 'inactive')
        ? 'active'
        : 'inactive';
    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus}),
      );
      if (response.statusCode == 200) {
        _statusUpdatedSuccessfully();
        fetchEmployees();
      } else {
        throw Exception('Error updating status');
      }
    } catch (e) {
      _errorUpdatingStatus();
    }
  }

  final Map<String, String> shiftTranslations = {
    'morning': 'morning'.tr(),
    'afternoon': 'afternoon'.tr(),
    'night': 'night'.tr(),
    'fulltime': 'fulltime'.tr(),
    'none': 'none'.tr(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('manage_shifts')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: searchController,
              onChanged: filterEmployees,
              decoration: InputDecoration(
                labelText: tr('search_employee'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredEmployees.isEmpty
                  ? Center(child: Text(tr('no_employees_found')))
                  : ListView.builder(
                      itemCount: filteredEmployees.length,
                      itemBuilder: (context, index) {
                        final employee = filteredEmployees[index];
                        final employeeStatus = employee['status'] ?? 'inactive';
                        return ListTile(
                          title: Text(employee['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('current_shift'.tr(
                                args: [
                                  employee['schedule'] != null
                                      ? shiftTranslations[
                                              employee['schedule']] ??
                                          'none'.tr()
                                      : 'none'.tr(),
                                ],
                              )),
                              Text('status'.tr(args: [
                                employeeStatus == 'active'
                                    ? 'active'.tr()
                                    : 'inactive'.tr(),
                              ])),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  employeeStatus == 'active'
                                      ? Icons.toggle_on
                                      : Icons.toggle_off,
                                  color: employeeStatus == 'active'
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                onPressed: () async {
                                  await toggleStatus(
                                    employee['id'].toString(),
                                    employeeStatus,
                                    employee['schedule'],
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          tr('update_shift'),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        content:
                                            DropdownButtonFormField<String>(
                                          value: selectedShift,
                                          isDense: false,
                                          items: shifts.map((shift) {
                                            return DropdownMenuItem<String>(
                                              value: shift['key'],
                                              child: Text(
                                                shift['value']!,
                                                style: const TextStyle(
                                                    fontSize: 13),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedShift = value;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            labelText: tr('select_shift'),
                                            border: const OutlineInputBorder(),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                    horizontal: 12),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(tr('cancel')),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              if (selectedShift != null) {
                                                await updateShift(
                                                  employee['id'].toString(),
                                                  selectedShift!,
                                                );
                                                _navigation();
                                              }
                                            },
                                            child: Text(tr('update')),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  await deleteShift(employee['id'].toString());
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _shiftUpdateSuccessfully() {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('shift_updated_successfully'))));
  }

  void _navigation() {
    Navigator.pop(context);
  }

  void _shiftDelatedSuccessfully() {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('shift_deleted_successfully'))));
  }

  void _errorUpdatingShift() {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(tr('error_updating_shift'))));
  }

  void _errorDeletingShift() {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(tr('error_deleting_shift'))));
  }

  void _errorLoadingData() {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(tr('error_loading_data'))));
  }

  void _cluesError() {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(tr('error_clues_not_found'))));
  }

  void _statusUpdatedSuccessfully() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('status_updated_successfully'))),
    );
  }

  void _errorUpdatingStatus() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('error_updating_status'))),
    );
  }
}
