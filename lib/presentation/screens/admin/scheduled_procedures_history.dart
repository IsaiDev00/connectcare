import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScheduledProceduresHistory extends StatefulWidget {
  final String hospitalId;

  const ScheduledProceduresHistory({super.key, required this.hospitalId});

  @override
  State<ScheduledProceduresHistory> createState() =>
      _ScheduledProceduresHistoryState();
}

class _ScheduledProceduresHistoryState
    extends State<ScheduledProceduresHistory> {
  List<dynamic> scheduledProcedures = [];
  int currentPage = 1;
  bool isLoading = false;
  String? filterDate;
  String? filterPatientName;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchScheduledProcedures();
  }

  Future<void> _fetchScheduledProcedures() async {
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
      final uri = Uri.parse('$baseUrl/agenda_procedimiento/history')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          scheduledProcedures = json.decode(response.body)['data'];
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

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) {
      return "n/a".tr();
    }
    try {
      final parsedTime = DateFormat.Hms().parse(time);
      return DateFormat('hh:mm a').format(parsedTime);
    } catch (e) {
      return "invalid_time".tr();
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
                _fetchScheduledProcedures();
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
                _fetchScheduledProcedures();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledProcedureDetails(Map<String, dynamic> procedure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: procedure.entries
          .where((entry) =>
              entry.key != 'id_agenda_procedimiento' &&
              entry.key != 'id_procedimiento')
          .map((entry) {
        final key = entry.key.replaceAll('_', ' ').toLowerCase();
        final value = entry.key == 'fecha'
            ? _formatDate(entry.value)
            : entry.key == 'hora_inicio' || entry.key == 'hora_fin'
                ? _formatTime(entry.value)
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
        title: Text("scheduled_procedures_history").tr(),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : scheduledProcedures.isEmpty
                    ? Center(child: Text("no_records_found").tr())
                    : ListView.builder(
                        itemCount: scheduledProcedures.length,
                        itemBuilder: (context, index) {
                          final procedure = scheduledProcedures[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _buildScheduledProcedureDetails(procedure),
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
                    _fetchScheduledProcedures();
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                currentPage++;
              });
              _fetchScheduledProcedures();
            },
          ),
        ],
      ),
    );
  }
}
