import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
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
  TextEditingController searchController = TextEditingController();

  void updateFilter(String query) {
    setState(() {
      filterHospitals = hospitals
          .where((medicament) =>
              medicament['nombre'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    medicamentsInit();
  }

  Future<void> medicamentsInit() async {
    var url = Uri.parse('$baseUrl/hospitales');
    var response = await http.get(url);
    final List<dynamic> data = json.decode(response.body);
    setState(() {
      hospitals = data.map((item) {
        return {
          'id': item['id_medicamento'].toString(),
          'nombre': item['nombre'],
        };
      }).toList();
      filterHospitals = List.from(hospitals);
    });
  }

  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  Widget _buildMenuItem(String title, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 20 : 15, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color.fromRGBO(169, 200, 149, 1) : Colors.grey,
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
                        SizedBox(
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
                                              // TODO send req and a toast
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
                                            icon: Icon(Icons
                                                .health_and_safety_outlined),
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, '/enterHospital');
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
