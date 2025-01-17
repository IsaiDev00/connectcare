import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MedicalInstructionsScreen extends StatefulWidget {
  final String nssPaciente;
  final String patientName;

  const MedicalInstructionsScreen({
    super.key,
    required this.nssPaciente,
    required this.patientName,
  });

  @override
  MedicalInstructionsScreenState createState() =>
      MedicalInstructionsScreenState();
}

class MedicalInstructionsScreenState extends State<MedicalInstructionsScreen> {
  List<Map<String, dynamic>> instructions = [];
  bool isLoading = true;
  int currentPage = 0;
  final int itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _fetchInstructions();
  }

  List<Map<String, dynamic>> _getPaginatedItems() {
    final startIndex = currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, instructions.length);
    return instructions.sublist(startIndex, endIndex);
  }

  void _nextPage() {
    if ((currentPage + 1) * itemsPerPage < instructions.length) {
      setState(() {
        currentPage++;
      });
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  Future<void> _fetchInstructions() async {
    final url = Uri.parse(
        '$baseUrl/indicaciones_medicas/indicaciones/${widget.nssPaciente}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          instructions =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        _noMedicalInstructions();
      }
    } catch (e) {
      _errorFetchingInstructions();
    }
  }

  void _errorFetchingInstructions() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching medical instructions'.tr())),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _noMedicalInstructions() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay indicaciones medicas aún'.tr())),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(String isoDate) {
    try {
      final DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Instructions'.tr()),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : instructions.isEmpty
              ? Center(child: Text('No medical instructions found'.tr()))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _getPaginatedItems().length,
                        itemBuilder: (context, index) {
                          final instruction = _getPaginatedItems()[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Diagnosis: ${instruction['diagnostico']}"
                                        .tr(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                      "Weight: ${instruction['peso']} kg".tr()),
                                  Text("RET: ${instruction['ret']}".tr()),
                                  Text("LNTP: ${instruction['lntp']}".tr()),
                                  Text("LVE: ${instruction['lve']}".tr()),
                                  const Divider(),
                                  Text("Formula: ${instruction['formula']}"
                                      .tr()),
                                  Text("Nutrition: ${instruction['nutricion']}"
                                      .tr()),
                                  Text("Solutions: ${instruction['soluciones']}"
                                      .tr()),
                                  Text(
                                      "Medications: ${instruction['medicamentos']}"
                                          .tr()),
                                  const Divider(),
                                  Text(
                                      "General Measures: ${instruction['medidas']}"
                                          .tr()),
                                  Text("CVC Care: ${instruction['cuidados']}"
                                      .tr()),
                                  Text("Pending: ${instruction['pendientes']}"
                                      .tr()),
                                  const Divider(),
                                  Text(
                                    "SAMM Use: ${instruction['uso_samm'] == 1 ? 'Yes' : 'No'}"
                                        .tr(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Date: ${_formatDate(instruction['fecha_hora'])}"
                                        .tr(),
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _previousPage,
                          child: Text("Previous".tr()),
                        ),
                        Text(
                          "Page ${currentPage + 1} of ${(instructions.length / itemsPerPage).ceil()}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        TextButton(
                          onPressed: _nextPage,
                          child: Text("Next".tr()),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}
