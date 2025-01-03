import 'dart:convert';
import 'package:connectcare/core/models/solicitud_a_hospital.dart';
import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;

import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/material.dart';

class ManageStaffUsers extends StatefulWidget {
  const ManageStaffUsers({super.key});

  @override
  State<ManageStaffUsers> createState() => _ManageStaffUsersState();
}

class _ManageStaffUsersState extends State<ManageStaffUsers> {
  String currentCLUES = '';

  Future<void> _loadUserData() async {
    final userData = await UserService().loadUserData();
    setState(() {
      currentCLUES = (userData['clues'] ?? '');
    });
  }

  String filterToLang(String f, bool lang) {
    switch (f) {
      case 'nombre':
        return lang ? 'nombre' : 'name';
      case 'id_personal':
        return 'id';
      case 'tipo':
        return lang ? 'tipo' : 'type';
      default:
        return 'err';
    }
  }

  List<String> filterTypes = ['nombre', 'id_personal', 'tipo'];
  int filterIndex = 0;
  List<Map<String, dynamic>> ids = [];
  List<Map<String, dynamic>> staff = [];
  List<Map<String, dynamic>> filterStaff = [];
  List<Map<String, dynamic>> requests = [];
  TextEditingController searchController = TextEditingController();
  String filter = 'nombre';
  void updateFilter(String query) {
    setState(() {
      filterStaff = staff.where((hospital) {
        final fieldValue = hospital[filter];
        final fieldString = fieldValue.toString().toLowerCase();
        return fieldString.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    if (mounted) {
      staffMembersInit();
      requestsToHospital();
      currentCLUES;
    }
  }

  String translateUserType(String userType) {
    switch (userType) {
      case 'administrator':
        return 'Administrator'.tr();
      case 'doctor':
        return 'Doctor'.tr();
      case 'nurse':
        return 'Nurse'.tr();
      case 'social worker':
        return 'Social Worker'.tr();
      case 'stretcher bearer':
        return 'Stretcher Bearer'.tr();
      case 'human resources':
        return 'Human Resources'.tr();
      default:
        return 'Unknown'.tr();
    }
  }

  Future<void> staffMembersInit() async {
    var url = Uri.parse('$baseUrl/personal_hospital');
    var response = await http.get(url);

    List<dynamic> ids = json.decode(response.body);

    ids = ids
        .where((item) => item['clues'] == currentCLUES)
        .map((item) => item['id_personal'])
        .toList();

    List<dynamic> dataStaff = [];
    for (var id in ids) {
      var individualUrl = Uri.parse('$baseUrl/personal/$id');
      var individualResponse = await http.get(individualUrl);

      if (individualResponse.statusCode == 200) {
        var responseData = json.decode(individualResponse.body);
        dataStaff.add(responseData);
      }
    }
    setState(() {
      staff = dataStaff.map((item) {
        return {
          'id_personal': item['id_personal'],
          'nombre': item['nombre'] ?? 'Unknown'.tr(),
          'apellido_paterno': item['apellido_paterno'] ?? 'Unknown'.tr(),
          'apellido_materno': item['apellido_materno'] ?? 'Unknown'.tr(),
          'tipo': item['tipo'] ?? 'Unknown',
          'correo_electronico': item['correo_electronico'] ?? 'Unknown'.tr(),
          'telefono': item['telefono'] ?? 'Unknown'.tr(),
          'estatus': item['estatus'] ?? 'Unknown'.tr(),
          'clues': item['clues'] ?? 'Unknown'.tr(),
        };
      }).toList();
      filterStaff = List.from(staff);
    });
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'.tr()),
          content: Text(
              'Are you sure you want to remove this member from the staff?'
                  .tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'.tr()),
            ),
            TextButton(
              onPressed: () async {
                await deleteStaffMember(id, currentCLUES);
              },
              child: Text('Remove'.tr()),
            ),
          ],
        );
      },
    );
  }

  Future<void> requestsToHospital() async {
    var url = Uri.parse('$baseUrl/solicitud_a_hospital/$currentCLUES');
    var response = await http.get(url);

    if (response.body.isNotEmpty) {
      try {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          requests = data.map((item) {
            return {
              'id_solicitud_a_hospital': item['id_solicitud_a_hospital'],
              'fecha': item['fecha'],
              'peticion': item['peticion'],
              'clues': item['clues'],
              'id_personal': item['id_personal']
            };
          }).toList();
        });
      } catch (e) {
        //showCustomSnackBar(context, "There are no requests".tr());
      }
    }
  }

  Future<void> deleteStaffMember(String id, String clues) async {
    try {
      var url = Uri.parse('$baseUrl/personal_hospital/$id/$clues');
      var response = await http.delete(url);
      _responseHandlerDeleteStaff(response);
    } catch (err) {
      // print(err);
    }

    staffMembersInit();
    setState(() {});
  }

  Future<void> deleteRequest(String id, String reason) async {
    try {
      final url = Uri.parse('$baseUrl/solicitud_a_hospital/$id');
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        setState(() {
          requests.removeWhere(
              (request) => request['id_solicitud_a_hospital'].toString() == id);
        });
        await staffMembersInit();
        _requestRejected();
      } else {
        _errorRejecting();
      }
    } catch (error) {
      _errorRejecting();
    }
  }

  Future<void> acceptUser(int idPersonal, int id, String email) async {
    try {
      final createUrl = Uri.parse('$baseUrl/personal_hospital');
      Map<String, dynamic> createBody = {
        "id_personal": idPersonal.toString(),
        "clues": currentCLUES,
      };

      final createResponse = await http.post(
        createUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(createBody),
      );

      if (createResponse.statusCode != 200 &&
          createResponse.statusCode != 201) {
        throw Exception('Failed to create personal_hospital record');
      }

      final emailUrl =
          Uri.parse('$baseUrl/solicitud_a_hospital/accept-request/$id');
      Map<String, dynamic> emailBody = {
        "email": email,
      };

      final emailResponse = await http.put(
        emailUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(emailBody),
      );

      if (emailResponse.statusCode != 200) {
        throw Exception('Failed to send acceptance email');
      }

      final deleteUrl = Uri.parse('$baseUrl/solicitud_a_hospital/$id');
      await http.delete(deleteUrl);

      setState(() {
        requests
            .removeWhere((request) => request['id_solicitud_a_hospital'] == id);
      });

      await staffMembersInit();
      _requestAccepted();
    } catch (error) {
      _errorRequest();
    }
  }

  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  Widget _buildMenuItem(String title, int index) {
    var theme = Theme.of(context);

    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 20 : 15, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.secondary
              : theme.colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  void _showBottomSheet({required String id, required String email}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        TextEditingController descriptionController = TextEditingController();
        var theme = Theme.of(context);

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          child: Column(
            children: [
              Text(id.toString()),
              TextField(
                controller: descriptionController,
                maxLines: 6,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Reason to decline user...".tr(),
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              Column(
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.send_rounded,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: () async {
                        if (descriptionController.text.isEmpty) {
                          Navigator.of(context).pop();
                          showCustomSnackBar(
                            context,
                            'Please provide a reason for rejection.'.tr(),
                          );
                        } else {
                          final url = Uri.parse(
                              '$baseUrl/solicitud_a_hospital/reject-request/$id');
                          final body = json.encode({
                            "email": email,
                            "reason": descriptionController.text,
                          });

                          final response = await http.post(
                            url,
                            headers: {'Content-Type': 'application/json'},
                            body: body,
                          );

                          if (response.statusCode == 200) {
                            await deleteRequest(id, descriptionController.text);
                          } else {
                            _errorRejecting();
                          }
                          _navigatorPop();
                        }
                      }),
                  Text(
                    'Send'.tr(),
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> crearSolicitudAHospital(
    String clues,
    String peticion,
    DateTime date,
    int idPersonal,
  ) async {
    final url = Uri.parse('$baseUrl/solicitud_a_hospital');

    String formattedDate = DateFormat('dd/MM/yyyy').format(date);

    SolicitudAHospital solicitud = SolicitudAHospital(
        fecha: formattedDate,
        peticion: peticion,
        clues: clues,
        idPersonal: idPersonal);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(solicitud.toMap()),
    );
    _responseHandlerDeleteStaff(response);
  }

  void _responseHandlerDeleteStaff(response) {
    Navigator.pop(context);

    responseHandlerDelete(response, context, 'Staff removed successfully'.tr(),
        'Couldnt remove staff user due to an error'.tr());
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMenuItem('Members'.tr(), 0),
                  _buildMenuItem('Requests'.tr(), 1),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Staff members'.tr(),
                            style: theme.textTheme.headlineLarge,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                            child: SizedBox(
                                width: 400,
                                child: ElevatedButton(
                                    onPressed: () {
                                      if (filterIndex > 1) {
                                        filterIndex = -1;
                                      }
                                      filterIndex++;
                                      setState(() {
                                        filter = filterTypes[filterIndex];
                                      });
                                    },
                                    child: Text('Toogle filter'.tr(args: [
                                      filterToLang(filter, false)
                                    ])))) //false because its eng,
                            ),
                        const SizedBox(height: 20),
                        Center(
                          child: SizedBox(
                            width: 400,
                            child: TextFormField(
                              controller: searchController,
                              onChanged: updateFilter,
                              decoration: InputDecoration(
                                labelText: "Search_by"
                                    .tr(args: [filterToLang(filter, false)]),
                                border: OutlineInputBorder(),
                              ),
                              autofocus: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the name of the hospital'
                                      .tr();
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: filterStaff.isEmpty
                              ? Center(
                                  child: Text(
                                    'No staff found'.tr(),
                                    style: TextStyle(fontSize: 18),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filterStaff.length,
                                  itemBuilder: (context, index) {
                                    final item = filterStaff[index];
                                    return ListTile(
                                      title: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Name_staff".tr(args: [
                                                      item['nombre'],
                                                      item['apellido_paterno'],
                                                      item['apellido_materno']
                                                    ]),
                                                    style: theme.textTheme
                                                        .headlineSmall,
                                                  ),
                                                  Text(
                                                    "ID_staff".tr(args: [
                                                      item['id_personal']
                                                          .toString()
                                                    ]),
                                                    style: theme.textTheme
                                                        .headlineSmall,
                                                  ),
                                                  Text(
                                                    "type_staff".tr(args: [
                                                      translateUserType(
                                                          item['tipo'] ??
                                                              'Unknown')
                                                    ]),
                                                    style: theme.textTheme
                                                        .headlineSmall,
                                                  ),
                                                  Text(
                                                    "email_staff".tr(args: [
                                                      item['correo_electronico']
                                                    ]),
                                                    style: theme.textTheme
                                                        .headlineSmall,
                                                  ),
                                                  Text(
                                                    "phone_staff".tr(args: [
                                                      item['telefono']
                                                    ]),
                                                    style: theme.textTheme
                                                        .headlineSmall,
                                                  ),
                                                ],
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                    Icons
                                                        .remove_circle_outline_outlined,
                                                    size: 25),
                                                onPressed: () => confirmDelete(
                                                    item['id_personal']
                                                        .toString()),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Divider()
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Hospital requests'.tr(),
                            style: theme.textTheme.headlineLarge,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: requests.isEmpty
                              ? Center(
                                  child: Text(
                                    'No requests found'.tr(),
                                    style: TextStyle(fontSize: 18),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: requests.length,
                                  itemBuilder: (context, index) {
                                    final item = requests[index];
                                    return ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "date_staff".tr(
                                                        args: [item['fecha']]),
                                                    style: theme.textTheme
                                                        .headlineSmall,
                                                  ),
                                                  Text(
                                                    "ID_staff".tr(args: [
                                                      item['id_personal']
                                                          .toString()
                                                    ]),
                                                    style: theme.textTheme
                                                        .headlineSmall,
                                                  ),
                                                ],
                                              ),
                                              IconButton(
                                                icon: Icon(Icons
                                                    .person_add_alt), // Nuevo icono
                                                onPressed: () async {
                                                  var url = Uri.parse(
                                                      '$baseUrl/personal/${item['id_personal']}');
                                                  var response =
                                                      await http.get(url);
                                                  var user = json
                                                      .decode(response.body);

                                                  await acceptUser(
                                                    item['id_personal'],
                                                    item[
                                                        'id_solicitud_a_hospital'],
                                                    user['correo_electronico']
                                                        .toString(),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(Icons
                                                    .person_remove_alt_1_outlined),
                                                onPressed: () async {
                                                  var url = Uri.parse(
                                                      '$baseUrl/personal/${item['id_personal']}');
                                                  var response =
                                                      await http.get(url);
                                                  var user = json
                                                      .decode(response.body);

                                                  _showBottomSheet(
                                                      id: item[
                                                              'id_solicitud_a_hospital']
                                                          .toString(),
                                                      email: user[
                                                              'correo_electronico']
                                                          .toString());
                                                },
                                              ),
                                            ],
                                          ),
                                          Text(
                                            "request_staff"
                                                .tr(args: [item['peticion']]),
                                            style:
                                                theme.textTheme.headlineSmall,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Divider()
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _requestRejected() {
    showCustomSnackBar(
      context,
      'The request was rejected successfully.'.tr(),
    );
  }

  void _errorRejecting() {
    showCustomSnackBar(
      context,
      'There was an error rejecting the request.'.tr(),
    );
  }

  void _navigatorPop() {
    Navigator.of(context).pop();
  }

  void _requestAccepted() {
    showCustomSnackBar(context, 'The request was accepted successfully.'.tr());
  }

  void _errorRequest() {
    showCustomSnackBar(context, 'Error accepting the request.'.tr());
  }
}
