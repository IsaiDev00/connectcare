import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicalInstructionsDetailsScreen extends StatefulWidget {
  final String nssPaciente;

  const MedicalInstructionsDetailsScreen(
      {super.key, required this.nssPaciente});

  @override
  MedicalInstructionsDetailsScreenState createState() =>
      MedicalInstructionsDetailsScreenState();
}

class MedicalInstructionsDetailsScreenState
    extends State<MedicalInstructionsDetailsScreen> {
  List<dynamic> instructions = [];
  int currentPage = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMedicalInstructions();
  }

  Future<void> _fetchMedicalInstructions() async {
    final url = Uri.parse(
        '$baseUrl/indicaciones_medicas/patient/${widget.nssPaciente}?page=$currentPage');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          instructions = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      //print('Error fetching medical instructions: $e');
    }
  }

  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) {
      return 'N/A';
    }
    try {
      final parsedDate = DateTime.parse(dateTime);
      return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Instructions Details'.tr()),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : instructions.isEmpty
              ? const Center(child: Text('No Medical Instructions Found'))
              : ListView.builder(
                  itemCount: instructions.length,
                  itemBuilder: (context, index) {
                    final instruction = instructions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Formula: ${instruction['formula']}'.tr(),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text('Nutrition: ${instruction['nutricion']}'.tr()),
                            Text(
                                'Solutions: ${instruction['soluciones']}'.tr()),
                            Text('LTP: ${instruction['lntp']}'.tr()),
                            Text('Diagnosis: ${instruction['diagnostico']}'
                                .tr()),
                            Text('LVE: ${instruction['lve']}'.tr()),
                            Text('RET: ${instruction['ret']}'.tr()),
                            Text('Measures: ${instruction['medidas']}'.tr()),
                            Text('Pending: ${instruction['pendientes']}'.tr()),
                            Text('Care: ${instruction['cuidados']}'.tr()),
                            Text('Medications: ${instruction['medicamentos']}'
                                .tr()),
                            Text(
                                'Weight: ${instruction['peso']?.toString() ?? 'N/A'} kg'
                                    .tr()),
                            Text(
                                'SAMM Use: ${instruction['uso_samm'] == 1 ? 'Yes'.tr() : 'No'.tr()}'),
                            Text(
                                'Date and Time: ${formatDateTime(instruction['fecha_hora'])}'
                                    .tr()),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: currentPage > 1
                ? () {
                    setState(() {
                      currentPage--;
                      isLoading = true;
                    });
                    _fetchMedicalInstructions();
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                currentPage++;
                isLoading = true;
              });
              _fetchMedicalInstructions();
            },
          ),
        ],
      ),
    );
  }
}
