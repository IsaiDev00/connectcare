import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

class ManageChiefs extends StatefulWidget {
  const ManageChiefs({super.key});

  @override
  State<ManageChiefs> createState() => _ManageChiefsState();
}

class _ManageChiefsState extends State<ManageChiefs> {
  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> filteredEmployees = [];
  List<Map<String, dynamic>> services = [];
  TextEditingController searchController = TextEditingController();
  String? selectedService;
  String? selectedRole;
  String? _clues;

  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  @override
  void initState() {
    super.initState();
    fetchClues();
  }

  Future<void> fetchClues() async {
    final data = await _sharedPreferencesService.getClues();
    setState(() {
      _clues = data ?? '';
    });
    if (_clues == null || _clues!.isEmpty) {
      showError(tr('error_clues_not_found'));
      return;
    }
    fetchEmployees();
    fetchServices();
  }

  Future<void> fetchEmployees() async {
    final url = Uri.parse('$baseUrl/chiefs/employees?clues=$_clues');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          employees = data
              .map((item) => {
                    'id': item['id'],
                    'name': item['name'],
                    'service': item['service'],
                    'type': item['type'],
                    'role': item['role'],
                  })
              .toList();
          filteredEmployees = List.from(employees);
        });
      } else {
        showError(tr('error_loading_data'));
      }
    } catch (e) {
      showError(tr('error_loading_data'));
    }
  }

  Future<void> fetchServices() async {
    final url = Uri.parse('$baseUrl/servicio/$_clues');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          services =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        showError(tr('error_loading_data'));
      }
    } catch (e) {
      showError(tr('error_loading_data'));
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

  Future<void> updateRole(
      String employeeId, String serviceId, String role) async {
    final url = Uri.parse('$baseUrl/chiefs/update');
    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_personal': employeeId,
          'id_servicio': serviceId,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        showSuccess(tr('role_updated_successfully'));
        fetchEmployees();
      } else if (response.statusCode == 400) {
        showError(tr('chief_already_exists_for_service'));
      } else {
        showError(tr('error_updating_role'));
      }
    } catch (e) {
      showError(tr('error_updating_role'));
    }
  }

  Future<void> deleteRole(String employeeId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(tr('confirm_delete')),
          content: Text(tr('are_you_sure_delete_role')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Cancelar
              },
              child: Text(tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true); // Confirmar
              },
              child: Text(tr('confirm')),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final url = Uri.parse('$baseUrl/chiefs/delete-role');
      try {
        final response = await http.patch(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'id_personal': employeeId}),
        );
        if (response.statusCode == 200) {
          showSuccess(tr('role_deleted_successfully'));
          fetchEmployees();
        } else {
          showError(tr('error_deleting_role'));
        }
      } catch (e) {
        showError(tr('error_deleting_role'));
      }
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  final Map<String, String> chiefTranslations = {
    'chief': 'chief'.tr(),
    'member': 'member'.tr(),
    'nurse': 'nurse'.tr(),
    'doctor': 'doctor'.tr(),
    'stretcher bearer': 'stretcher bearer'.tr(),
    'none': 'none'.tr(),
    'oncology': 'oncology'.tr(),
    'neurology': 'neurology'.tr(),
    'radiology': 'radiology'.tr(),
    'laboratory': 'laboratory'.tr(),
    'cardiology': 'cardiology'.tr(),
    'orthopedics': 'orthopedics'.tr(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('manage_chiefs')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: filterEmployees,
              decoration: InputDecoration(
                labelText: tr('search_employee'),
                border: const OutlineInputBorder(),
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
                        return ListTile(
                          title: Text(employee['name'],
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('service'.tr(
                                args: [
                                  employee['service'] != null
                                      ? chiefTranslations[
                                              employee['service']] ??
                                          'none'.tr()
                                      : 'none'.tr(),
                                ],
                              )),
                              Text('role'.tr(
                                args: [
                                  employee['role'] != null
                                      ? chiefTranslations[employee['role']] ??
                                          'none'.tr()
                                      : 'none'.tr(),
                                ],
                              )),
                              Text('user_type'.tr(
                                args: [
                                  employee['type'] != null
                                      ? chiefTranslations[employee['type']] ??
                                          'none'.tr()
                                      : 'none'.tr(),
                                ],
                              )),
                              Divider(color: Theme.of(context).dividerColor),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(tr('update_role')),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            DropdownButtonFormField<String>(
                                              value: selectedService,
                                              items: services.map((service) {
                                                return DropdownMenuItem<String>(
                                                  value: service['id_servicio']
                                                      .toString(),
                                                  child: Text(
                                                    tr(service[
                                                        'nombre_servicio']),
                                                    style: const TextStyle(
                                                        fontSize: 13),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedService = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                labelText: tr('select_service'),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            DropdownButtonFormField<String>(
                                              value: selectedRole,
                                              items: [
                                                {
                                                  'key': 'chief',
                                                  'value': tr('chief')
                                                }, // Traduce aquí
                                                {
                                                  'key': 'member',
                                                  'value': tr('member')
                                                }, // Traduce aquí
                                              ].map((role) {
                                                return DropdownMenuItem<String>(
                                                  value: role['key'],
                                                  child: Text(
                                                    role['value']!,
                                                    style: const TextStyle(
                                                        fontSize: 13),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedRole = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                labelText: tr('select_role'),
                                              ),
                                            ),
                                          ],
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
                                              if (selectedService != null &&
                                                  selectedRole != null) {
                                                await updateRole(
                                                  employee['id'].toString(),
                                                  selectedService!,
                                                  selectedRole!,
                                                );
                                                _navigation();
                                              } else {
                                                showError(
                                                    tr('select_all_fields'));
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
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await deleteRole(employee['id'].toString());
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

  void _navigation() {
    Navigator.pop(context);
  }
}
