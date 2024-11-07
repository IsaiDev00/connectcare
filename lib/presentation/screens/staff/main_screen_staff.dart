import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/core/models/solicitud_a_hospital.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
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
    hospitalsInit();
    myHospitalsInit();
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
      print(hospitals);
      filterHospitals = List.from(hospitals);
    });
  }

  Future<void> myHospitalsInit() async {
    int currentPersonalId = 21100286;
    var url =
        Uri.parse('$baseUrl/personal_hospital/personal/$currentPersonalId');
    var response = await http.get(url);
    final List<dynamic> data = json.decode(response.body);
    setState(() {
      myHospitals = data.map((item) {
        return {'clues': item['clues'], 'nombre': item['nombre_hospital']};
      }).toList();
    });
    print(myHospitals);
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

  void _showBottomSheet(
      {required String name,
      required String clues,
      required DateTime date,
      required int idPersonal}) {
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
              Text(name),
              TextField(
                controller: descriptionController,
                maxLines: 6,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: "Carta de solicitud...",
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
                    onPressed: () {
                      crearSolicitudAHospital(
                        clues,
                        descriptionController.text,
                        date,
                        idPersonal,
                      );
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
    SolicitudAHospital solicitud = SolicitudAHospital(
        fecha: date, peticion: peticion, clues: clues, idPersonal: idPersonal);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(solicitud.toMap()),
    );
    _responseHandlerPost(response);
  }

  _responseHandlerPost(response) {
    responseHandlerPost(response, context, 'Solicitud creada con exito',
        'Error al crear solicitud');
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
                  _buildMenuItem('Solicitar', 0),
                  _buildMenuItem('Registrados', 1),
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
                            'Solicitar ingreso a hospital',
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
                              decoration: const InputDecoration(
                                labelText: "Search...",
                                border: OutlineInputBorder(),
                              ),
                              autofocus: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese el nombre del hospital';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: filterHospitals.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No se encontraron hospitales',
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
                                              _showBottomSheet(
                                                  name: item['nombre'],
                                                  clues: item['clues'],
                                                  date: now,
                                                  idPersonal: 4);
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
                            'Tus hospitales registrados',
                            style: theme.textTheme.headlineLarge,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: myHospitals.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No se encontraron hospitales',
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
                                                  // Navigator.pushNamed(context,
                                                  //     '/enterHospital');
                                                },
                                              ),
                                              Text(
                                                'Ingresar',
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
}
