import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicalInstructionsHistory extends StatefulWidget {
  final String hospitalId;

  const MedicalInstructionsHistory({super.key, required this.hospitalId});

  @override
  State<MedicalInstructionsHistory> createState() =>
      _MedicalInstructionsHistoryState();
}

class _MedicalInstructionsHistoryState
    extends State<MedicalInstructionsHistory> {
  List<dynamic> medicalInstructions = [];
  int currentPage = 1;
  bool isLoading = false;
  String? filterDate;
  String? filterPatientName;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMedicalInstructions();
  }

  Future<void> _fetchMedicalInstructions() async {
    setState(() {
      isLoading = true;
    });

    final queryParams = {
      'hospitalId': widget.hospitalId,
      'page': currentPage.toString(),
      if (filterDate != null && filterDate!.isNotEmpty) 'fecha': filterDate!,
      if (filterPatientName != null && filterPatientName!.isNotEmpty)
        'nombrePaciente': filterPatientName!,
    };

    try {
      final uri = Uri.parse('$baseUrl/indicaciones_medicas/history')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          medicalInstructions = json.decode(response.body)['data'];
        });
      } else {
        //print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      //print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) {
      return "n/a".tr();
    }
    try {
      final parsedDateTime = DateTime.parse(dateTime);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedDateTime);
    } catch (e) {
      return "invalid_date_time".tr();
    }
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "filter_by_patient_name".tr(),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                filterPatientName = value;
                _fetchMedicalInstructions();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: "filter_by_date".tr(),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                filterDate = value;
                _fetchMedicalInstructions();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInstructionDetails(Map<String, dynamic> instruction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: instruction.entries
          .where((entry) =>
              entry.key != 'id_indicaciones_medicas' &&
              entry.key != 'nss_paciente')
          .map((entry) {
        final key = entry.key.replaceAll('_', ' ').toLowerCase();
        final value = entry.key == 'fecha_hora'
            ? _formatDateTime(entry.value)
            : entry.value != null && entry.value.toString().isNotEmpty
                ? entry.value.toString()
                : "n/a".tr();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            "${key.tr()}: ${value.tr()}",
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("medical_instructions_history").tr(),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : medicalInstructions.isEmpty
                    ? Center(child: Text("no_records_found").tr())
                    : ListView.builder(
                        itemCount: medicalInstructions.length,
                        itemBuilder: (context, index) {
                          final instruction = medicalInstructions[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child:
                                  _buildMedicalInstructionDetails(instruction),
                            ),
                          );
                        },
                      ),
          ),
        ],
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
              });
              _fetchMedicalInstructions();
            },
          ),
        ],
      ),
    );
  }
}
