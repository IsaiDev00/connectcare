import 'dart:convert';

import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:connectcare/presentation/screens/admin/create_medicament_screen.dart';
import 'package:connectcare/presentation/screens/admin/update_medicament.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;

class ManageMedications extends StatefulWidget {
  const ManageMedications({super.key});

  @override
  State<ManageMedications> createState() => _ManageMedicationsState();
}

class _ManageMedicationsState extends State<ManageMedications> {
  List<Map<String, dynamic>> medicaments = [];
  List<Map<String, dynamic>> filterMedicaments = [];
  TextEditingController searchController = TextEditingController();
  String _clues = '';
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  @override
  void initState() {
    super.initState();
    medicamentsInit();
  }

  Future<void> medicamentsInit() async {
    final data = await _sharedPreferencesService.getClues();
    setState(() {
      _clues = data ?? '';
    });

    var url = Uri.parse('$baseUrl/medicamento?clues=$_clues');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          medicaments = data.map((item) {
            return {
              'id': item['id_medicamento'].toString(),
              'nombre': item['nombre'],
            };
          }).toList();
          filterMedicaments = List.from(medicaments);
        });
      } else {
        throw Exception('error_fetching_medicines'.tr());
      }
    } catch (e) {
      // print("Error: $e");
    }
  }

  void updateFilter(String query) {
    setState(() {
      filterMedicaments = medicaments
          .where((medicament) =>
              medicament['nombre'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> deleteMedicament(String id) async {
    var url = Uri.parse('$baseUrl/medicamento/$id');
    await http.delete(url);
    _responseHandlerPost();

    medicamentsInit();
    setState(() {});
  }

  _responseHandlerPost() {
    showCustomSnackBar(context, "medicine_deleted_successfully".tr());
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('manage_medicines'.tr()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              SizedBox(
                width: 400,
                child: TextFormField(
                  controller: searchController,
                  onChanged: updateFilter,
                  decoration: InputDecoration(
                    labelText: "search".tr(),
                    border: const OutlineInputBorder(),
                  ),
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'enter_medicine_name'.tr();
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              filterMedicaments.isEmpty
                  ? SizedBox(
                      height: 450,
                      child: Center(
                        child: Text(
                          'nothing_to_see'.tr(),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    )
                  :
                  //  Expanded(
                  SizedBox(
                      height: 450,
                      child: ListView.builder(
                        itemCount: filterMedicaments.length,
                        itemBuilder: (context, index) {
                          final item = filterMedicaments[index];
                          return ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['nombre'],
                                  style: theme.textTheme.headlineSmall,
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UpdateMedicamentScreen(
                                                    id: item['id']),
                                          ),
                                        );

                                        if (result == 'updated') {
                                          await medicamentsInit();
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        await deleteMedicament(item['id']);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const CreateMedicamentScreen()));
                    if (result == 'created') {
                      await medicamentsInit();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text('add_medicine'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
