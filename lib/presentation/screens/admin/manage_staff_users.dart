import 'dart:convert';
import 'package:connectcare/core/models/solicitud_a_hospital.dart';
import 'package:connectcare/data/api/resend.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:http/http.dart' as http;

import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageStaffUsers extends StatefulWidget {
  const ManageStaffUsers({super.key});

  @override
  State<ManageStaffUsers> createState() => _ManageStaffUsersState();
}

class _ManageStaffUsersState extends State<ManageStaffUsers> {
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

  String currentCLUES = 'ASDIF000011';

  @override
  void initState() {
    super.initState();
    if (mounted) {
      staffMembersInit();
      requestsToHospital();
      currentCLUES;
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
          'nombre': item['nombre'] ?? 'Unknown',
          'apellido_paterno': item['apellido_paterno'] ?? 'Unknown',
          'apellido_materno': item['apellido_materno'] ?? 'Unknown',
          'tipo': item['tipo'] ?? 'Unknown',
          'correo_electronico': item['correo_electronico'] ?? 'Unknown',
          'telefono': item['telefono'] ?? 'Unknown',
          'estatus': item['estatus'] ?? 'Not Available',
          'clues': item['clues'] ?? 'Not Available',
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
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to remove this member from the staff?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await deleteStaffMember(id, currentCLUES);
              },
              child: const Text('Remove'),
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
      var url = Uri.parse('$baseUrl/solicitud_a_hospital/$id');
      var response = await http.delete(url);

      _responseHandlerDeleteRequest(response);
    } catch (error) {
      // print(error);
    }

    requestsToHospital();
    setState(() {});
  }

  Future<void> acceptUser(int idPersonal, int id) async {
    final url = Uri.parse('$baseUrl/personal_hospital');
    try {
      Map req = {
        "id_personal": idPersonal.toString(),
        "clues": currentCLUES,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(req),
      );

      _responseHandlerPostPersonalHospital(response);
      var urlDelete = Uri.parse('$baseUrl/solicitud_a_hospital/$id');
      await http.delete(urlDelete);
    } catch (error) {
      // print(error);
    }
    requestsToHospital();

    staffMembersInit();
    setState(() {});
  }

  void _responseHandlerPostPersonalHospital(response) {
    responseHandlerPost(response, context, 'Staff added successfully',
        'Error adding user staff');
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
    final resendService = ResendService();

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
                decoration: const InputDecoration(
                  labelText: "Reason to decline user...",
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
                      await resendService.sendReportRequestEmail(
                        rejectionReason: descriptionController.text,
                        sender: 'recipient@example.com',
                      );
                      await deleteRequest(id, descriptionController.text);
                    },
                  ),
                  Text(
                    'Enviar',
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

    responseHandlerDelete(response, context, 'Staff removed successfully',
        'Couldnt remove staff user due to an error');
  }

  void _responseHandlerDeleteRequest(response) {
    Navigator.pop(context);

    responseHandlerDelete(response, context, 'Staff removed successfully',
        'Couldnt remove staff user due to an error');
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
                  _buildMenuItem('Members', 0),
                  _buildMenuItem('Requests', 1),
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
                            'Staff members',
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
                                    child: Text(
                                        'Toogle filter: ${filterToLang(filter, false)}'))) //false because its eng,
                            ),
                        const SizedBox(height: 20),
                        Center(
                          child: SizedBox(
                            width: 400,
                            child: TextFormField(
                              controller: searchController,
                              onChanged: updateFilter,
                              decoration: InputDecoration(
                                labelText:
                                    "Search by ${filterToLang(filter, false)}...",
                                border: OutlineInputBorder(),
                              ),
                              autofocus: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese el name del hospital';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: filterStaff.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No se encontro personal',
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
                                                    "Name: ${item['nombre']} ${item['apellido_paterno']} ${item['apellido_materno']}",
                                                    style: theme.textTheme
                                                        .headlineSmall,
                                                  ),
                                                  Text(
                                                    "ID: ${item['id_personal']}",
                                                    style: theme.textTheme
                                                        .headlineSmall,
                                                  ),
                                                  Text(
                                                    "Type: ${item['tipo']}",
                                                    style: theme.textTheme
                                                        .headlineSmall,
                                                  ),
                                                  Text(
                                                    "Email: ${item['correo_electronico']}",
                                                    style: theme.textTheme
                                                        .headlineSmall,
                                                  ),
                                                  Text(
                                                    "Phone: ${item['telefono']}",
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
                            'Hospital requests',
                            style: theme.textTheme.headlineLarge,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: requests.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No se encontraron solicitudes',
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
                                                    "Date: ${item['fecha']}",
                                                    style: theme.textTheme
                                                        .headlineSmall,
                                                  ),
                                                  Text(
                                                    "ID: ${item['id_personal']}",
                                                    style: theme.textTheme
                                                        .headlineSmall,
                                                  ),
                                                ],
                                              ),
                                              IconButton(
                                                  icon: Icon(Icons
                                                      .person_add_outlined),
                                                  onPressed: () => acceptUser(
                                                      item['id_personal'],
                                                      item[
                                                          'id_solicitud_a_hospital'])),
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
                                                  //email: 'damian.pebe@gmail.com'); //this is a temp email to verify only
                                                },
                                              ),
                                            ],
                                          ),
                                          Text(
                                            "Request: ${item['peticion']}",
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
}
