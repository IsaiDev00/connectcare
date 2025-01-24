import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TriageHistory extends StatefulWidget {
  final String hospitalId;

  const TriageHistory({super.key, required this.hospitalId});

  @override
  State<TriageHistory> createState() => _TriageHistoryState();
}

class _TriageHistoryState extends State<TriageHistory> {
  List<dynamic> triageRecords = [];
  int currentPage = 1;
  bool isLoading = false;
  String? filterEndDate;
  String? filterPatientName;

  final TextEditingController endDateController = TextEditingController();
  final TextEditingController patientNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTriageRecords();
  }

  Future<void> _fetchTriageRecords() async {
    setState(() {
      isLoading = true;
    });

    final queryParams = {
      'hospitalId': widget.hospitalId,
      'page': currentPage.toString(),
      if (filterEndDate != null && filterEndDate!.isNotEmpty)
        'fechaFin': filterEndDate!,
      if (filterPatientName != null && filterPatientName!.isNotEmpty)
        'nombrePaciente': filterPatientName!,
    };

    try {
      final uri = Uri.parse('$baseUrl/triage/history')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          triageRecords = json.decode(response.body)['data'];
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

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return "n/a".tr();
    }
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return "invalid_date".tr();
    }
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: patientNameController,
              decoration: InputDecoration(
                labelText: "filter_by_patient_name".tr(),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                filterPatientName = value;
                _fetchTriageRecords();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: endDateController,
              decoration: InputDecoration(
                labelText: "filter_by_end_date".tr(),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                filterEndDate = value;
                _fetchTriageRecords();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriageRecordDetails(Map<String, dynamic> record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: record.entries
          .where(
              (entry) => entry.key != 'id_triage' && entry.key != 'id_medico')
          .map((entry) {
        final key = entry.key.replaceAll('_', ' ').toLowerCase();
        final value = entry.key.contains('fecha') || entry.key.contains('hora')
            ? _formatDate(entry.value)
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
        title: const Text("triage_history").tr(),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : triageRecords.isEmpty
                    ? Center(child: const Text("no_records_found").tr())
                    : ListView.builder(
                        itemCount: triageRecords.length,
                        itemBuilder: (context, index) {
                          final record = triageRecords[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _buildTriageRecordDetails(record),
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
                    _fetchTriageRecords();
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                currentPage++;
              });
              _fetchTriageRecords();
            },
          ),
        ],
      ),
    );
  }
}
