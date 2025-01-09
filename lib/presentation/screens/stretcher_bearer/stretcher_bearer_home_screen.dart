import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/user_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StretcherBearerHomeScreen extends StatefulWidget {
  const StretcherBearerHomeScreen({super.key});

  @override
  StretcherBearerHomeScreenState createState() =>
      StretcherBearerHomeScreenState();
}

class StretcherBearerHomeScreenState extends State<StretcherBearerHomeScreen> {
  String? stretcherBearerId;
  List<Map<String, dynamic>> patients = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _loadStretcherBearerData();
  }

  Future<void> _loadStretcherBearerData() async {
    final userData = await UserService().loadUserData();
    setState(() {
      stretcherBearerId = userData['userId'];
    });
    if (stretcherBearerId != null) {
      await _fetchPatients();
    }
  }

  Future<void> _fetchPatients() async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse(
        '$baseUrl/assign_tasks/stretcher_bearer/patients/$stretcherBearerId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          patients = data
              .map((item) => {
                    'id': item['id'],
                    'name': item['name'],
                    'bed_number': item['bed_number'],
                    'age': item['age'],
                  })
              .toList();
          filteredPatients = List.from(patients);
        });
      } else {
        _errorFetchingPatients();
      }
    } catch (e) {
      _errorFetchingPatients();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterPatients(String query) {
    setState(() {
      filteredPatients = patients
          .where((patient) =>
              patient['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: _filterPatients,
              decoration: InputDecoration(
                labelText: "Search Patients".tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: filteredPatients.isEmpty
                        ? Center(child: Text("No patients assigned".tr()))
                        : ListView.builder(
                            itemCount: filteredPatients.length,
                            itemBuilder: (context, index) {
                              final patient = filteredPatients[index];
                              return ListTile(
                                title: Text(patient['name']),
                                subtitle: Text("info_patient".tr(args: [
                                  patient['bed_number'].toString(),
                                  patient['age'].toString(),
                                  patient['id'].toString()
                                ])),
                                onTap: null,
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }

  void _errorFetchingPatients() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching patients'.tr())),
    );
  }
}
