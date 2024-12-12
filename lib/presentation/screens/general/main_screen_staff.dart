import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/core/models/solicitud_a_hospital.dart';
import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/presentation/screens/general/auth/login/login_screen.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MainScreenStaff extends StatefulWidget {
  const MainScreenStaff({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreenStaff> {
  List<Map<String, dynamic>> hospitals = [];
  List<Map<String, dynamic>> filterHospitals = [];
  List<Map<String, dynamic>> myHospitals = [];
  TextEditingController searchController = TextEditingController();
  int? idPersonal;
  String? userId;
  String? userType;

  void updateFilter(String query) {
    setState(() {
      filterHospitals = hospitals
          .where((hospital) =>
              hospital['nombre'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadCurrentPersonalId();
  }

  Future<void> loadCurrentPersonalId() async {
    final userData = await UserService().loadUserData();
    setState(() {
      userId = userData['userId'];
      userType = userData['userType'];
    });

    if (userId != null && userId!.isNotEmpty) {
      final url = Uri.parse('$baseUrl/auth/user_by_id/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        if (userData['id'] != null) {
          setState(() {
            idPersonal = int.tryParse(userData['id'].toString());
          });
          await hospitalsInit();
          await myHospitalsInit();
        } else {
          _personalError();
        }
      } else {
        _unauthenticatedUser();
      }
    } else {
      _unauthenticatedUser();
    }
  }

  Future<void> hospitalsInit() async {
    var url = Uri.parse('$baseUrl/hospital');
    var response = await http.get(url);
    final List<dynamic> data = json.decode(response.body);
    setState(() {
      hospitals = data.map((item) {
        return {
          'clues': item['clues'],
          'nombre': item['nombre'],
        };
      }).toList();
      filterHospitals = List.from(hospitals);
    });
  }

  Future<void> myHospitalsInit() async {
    if (idPersonal == null) {
      showCustomSnackBar(context, 'Error: No valid Personalid found.'.tr());
      return;
    }

    final url = Uri.parse('$baseUrl/personal_hospital/personal/$idPersonal');
    final response = await http.get(url);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        myHospitals = data.map((item) {
          return {'clues': item['clues'], 'nombre': item['nombre_hospital']};
        }).toList();
      });
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

  void _showBottomSheet({
    required String name,
    required String clues,
    required DateTime date,
  }) {
    if (idPersonal == null) {
      showCustomSnackBar(context, 'Error: User not authenticated.'.tr());
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        TextEditingController descriptionController = TextEditingController();
        var theme = Theme.of(context);

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.headlineSmall,
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        maxLines: 6,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Request letter...".tr(),
                          border: OutlineInputBorder(),
                        ),
                        autofocus: true,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.send_rounded,
                              color: theme.colorScheme.onSurface,
                            ),
                            onPressed: () {
                              if (descriptionController.text.isEmpty) {
                                Navigator.of(context).pop();
                                showCustomSnackBar(
                                  context,
                                  'Please provide a reason for your request.'
                                      .tr(),
                                );
                              } else {
                                Navigator.of(context).pop();
                                crearSolicitudAHospital(
                                  clues,
                                  descriptionController.text,
                                  date,
                                  idPersonal!,
                                );
                              }
                            },
                          ),
                          Text(
                            'Send'.tr(),
                            style: theme.textTheme.bodyLarge!.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    _responseHandlerPost(response);
  }

  _responseHandlerPost(response) {
    if (response.statusCode == 201) {
      showCustomSnackBar(
        context,
        'Request created successfully'.tr(),
      );
    } else {
      showCustomSnackBar(
        context,
        'Error creating request'.tr(),
      );
    }
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
                  _buildMenuItem('Request'.tr(), 0),
                  _buildMenuItem('Registered'.tr(), 1),
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
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Request admission to hospital'.tr(),
                            style: theme.textTheme.headlineLarge,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: SizedBox(
                            width: 400,
                            child: TextFormField(
                              controller: searchController,
                              onChanged: updateFilter,
                              decoration: InputDecoration(
                                labelText: "Search...".tr(),
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
                          child: filterHospitals.isEmpty
                              ? Center(
                                  child: Text(
                                    'No hospitals found'.tr(),
                                    style: TextStyle(fontSize: 18),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filterHospitals.length,
                                  itemBuilder: (context, index) {
                                    final item = filterHospitals[index];
                                    return ListTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item['nombre'],
                                            style:
                                                theme.textTheme.headlineSmall,
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.send_rounded),
                                            onPressed: () {
                                              DateTime now = DateTime.now();
                                              if (idPersonal != null) {
                                                _showBottomSheet(
                                                  name: item['nombre'],
                                                  clues: item['clues'],
                                                  date: now,
                                                );
                                              } else {
                                                showCustomSnackBar(
                                                    context,
                                                    'Error: User not authenticated.'
                                                        .tr());
                                              }
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Your registered hospitals'.tr(),
                            style: theme.textTheme.headlineLarge,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: myHospitals.isEmpty
                              ? Center(
                                  child: Text(
                                    'No hospitals found'.tr(),
                                    style: TextStyle(fontSize: 18),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: myHospitals.length,
                                  itemBuilder: (context, index) {
                                    final item = myHospitals[index];
                                    return ListTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item['nombre'],
                                            style:
                                                theme.textTheme.headlineSmall,
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons
                                                    .health_and_safety_outlined),
                                                onPressed: () {
                                                  showCustomSnackBar(
                                                      context, item['clues']);
                                                },
                                              ),
                                              Text(
                                                'Get into'.tr(),
                                                style:
                                                    theme.textTheme.bodyLarge,
                                              )
                                            ],
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _unauthenticatedUser() {
    showCustomSnackBar(
        context, 'Error: User not authenticated. Please login.'.tr());
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  void _personalError() {
    showCustomSnackBar(
      context,
      'Error: Could not get personalid. Please try again.'.tr(),
    );
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
