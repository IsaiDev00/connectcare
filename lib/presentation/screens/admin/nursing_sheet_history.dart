import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NursingSheetHistory extends StatefulWidget {
  final String hospitalId;

  const NursingSheetHistory({super.key, required this.hospitalId});

  @override
  State<NursingSheetHistory> createState() => _NursingSheetHistoryState();
}

class _NursingSheetHistoryState extends State<NursingSheetHistory> {
  List<dynamic> nursingRecords = [];
  int currentPage = 1;
  bool isLoading = false;
  String? filterDate;
  String? filterPatientName;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNursingRecords();
  }

  Future<void> _fetchNursingRecords() async {
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
      final uri = Uri.parse('$baseUrl/hoja_de_enfermeria/history')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          nursingRecords = json.decode(response.body)['data'];
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
      return DateFormat('yyyy-MM-dd').format(parsedDate);
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
              controller: nameController,
              decoration: InputDecoration(
                labelText: "filter_by_patient_name".tr(),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                filterPatientName = value;
                _fetchNursingRecords();
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
                _fetchNursingRecords();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNursingRecordDetails(Map<String, dynamic> record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: record.entries
          .where((entry) =>
              entry.key != 'id_hoja_de_enfermeria' && entry.key != 'id_medico')
          .map((entry) {
        final key = entry.key.replaceAll('_', ' ').toLowerCase();
        final value = entry.key == 'fecha'
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
        title: const Text("nursing_sheet_history").tr(),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : nursingRecords.isEmpty
                    ? Center(child: const Text("no_records_found").tr())
                    : ListView.builder(
                        itemCount: nursingRecords.length,
                        itemBuilder: (context, index) {
                          final record = nursingRecords[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _buildNursingRecordDetails(record),
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
                    _fetchNursingRecords();
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                currentPage++;
              });
              _fetchNursingRecords();
            },
          ),
        ],
      ),
    );
  }
}
