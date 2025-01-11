import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SocialWorkerHomeScreen extends StatefulWidget {
  const SocialWorkerHomeScreen({super.key});

  @override
  SocialWorkerHomeScreenState createState() => SocialWorkerHomeScreenState();
}

class SocialWorkerHomeScreenState extends State<SocialWorkerHomeScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> filteredPatients = [];
  List<Map<String, dynamic>> paginatedPatients = [];
  bool isLoading = true;
  String clues = '';
  String userId = '';
  int currentPage = 0;
  final int itemsPerPage = 10;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    final data = await _userService.loadUserData();
    setState(() {
      userId = (data['userId'] ?? '');
      clues = (data['clues'] ?? '');
      isLoading = true;
    });

    final url = Uri.parse('$baseUrl/family_link/social_worker/patients/$clues');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          patients = data
              .map((item) => {
                    'nss': item['nss'],
                    'name': item['nombre'],
                    'age': item['edad'],
                  })
              .toList();
          filteredPatients = List.from(patients);
          _updatePagination();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error fetching patients')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching patients')),
        );
      }
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
      currentPage = 0; // Reinicia a la primera página al filtrar
      _updatePagination();
    });
  }

  void _updatePagination() {
    final startIndex = currentPage * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    setState(() {
      paginatedPatients = filteredPatients.sublist(
          startIndex,
          endIndex > filteredPatients.length
              ? filteredPatients.length
              : endIndex);
    });
  }

  void _nextPage() {
    if ((currentPage + 1) * itemsPerPage < filteredPatients.length) {
      setState(() {
        currentPage++;
        _updatePagination();
      });
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        _updatePagination();
      });
    }
  }

  void _showCodeDialog(String nss) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Generate Link Code",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.star,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  "Principal",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () => _generateCode(nss, 'main'),
              ),
              Divider(color: Theme.of(context).dividerColor),
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  "Regular",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () => _generateCode(nss, 'regular'),
              ),
              Divider(color: Theme.of(context).dividerColor),
              ListTile(
                leading: Icon(
                  Icons.link,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  "Occasional Connection",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () => _generateCode(nss, 'occasional'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateCode(String nss, String relacion) async {
    final url = Uri.parse('$baseUrl/family_link/generate-code');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nss_paciente': nss,
          'relacion': relacion,
          'id_personal': userId,
        }),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (mounted) {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Code Generated"),
                content: Text("Code: ${data['code']}"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error generating code')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error generating code')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Social Worker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: _filterPatients,
              decoration: const InputDecoration(
                labelText: "Search Patients",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: paginatedPatients.isEmpty
                              ? const Center(child: Text("No patients found"))
                              : ListView.builder(
                                  itemCount: paginatedPatients.length,
                                  itemBuilder: (context, index) {
                                    final patient = paginatedPatients[index];
                                    return ListTile(
                                      title: Text(patient['name']),
                                      subtitle: Text(
                                          "Age: ${patient['age']} | NSS: ${patient['nss']}"),
                                      onTap: () => _showCodeDialog(
                                          patient['nss'].toString()),
                                    );
                                  },
                                ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _previousPage,
                              child: const Text("Previous"),
                            ),
                            Text(
                              "Page ${currentPage + 1} of ${(filteredPatients.length / itemsPerPage).ceil()}",
                            ),
                            TextButton(
                              onPressed: _nextPage,
                              child: const Text("Next"),
                            ),
                          ],
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
