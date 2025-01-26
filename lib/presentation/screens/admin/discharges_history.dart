import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DischargesHistory extends StatefulWidget {
  final String hospitalId;

  const DischargesHistory({super.key, required this.hospitalId});

  @override
  State<DischargesHistory> createState() => _DischargesHistoryState();
}

class _DischargesHistoryState extends State<DischargesHistory> {
  List<dynamic> discharges = [];
  int currentPage = 1;
  bool isLoading = false;
  String? filterDate;
  String? filterPatientName;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDischarges();
  }

  Future<void> _fetchDischarges() async {
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
      final uri = Uri.parse('$baseUrl/paciente/history')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          discharges = json.decode(response.body)['data'];
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
                _fetchDischarges();
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
                _fetchDischarges();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDischargeDetails(Map<String, dynamic> record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("patient_name"
            .tr(args: [record['paciente_nombre_completo'] ?? "n/a"])),
        Text(
            "discharge_reason".tr(args: [record['discharge_reason'] ?? "n/a"])),
        Text(
            "discharge_date".tr(args: [_formatDate(record['discharge_date'])])),
        Text("doctor_name"
            .tr(args: [record['medico_nombre_completo'] ?? "n/a"])),
      ]
          .map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0), child: e))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("discharges_history").tr(),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : discharges.isEmpty
                    ? Center(child: const Text("no_records_found").tr())
                    : ListView.builder(
                        itemCount: discharges.length,
                        itemBuilder: (context, index) {
                          final record = discharges[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _buildDischargeDetails(record),
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
                    _fetchDischarges();
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                currentPage++;
              });
              _fetchDischarges();
            },
          ),
        ],
      ),
    );
  }
}
