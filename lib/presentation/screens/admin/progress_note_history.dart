import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProgressNoteHistory extends StatefulWidget {
  final String hospitalId;

  const ProgressNoteHistory({super.key, required this.hospitalId});

  @override
  State<ProgressNoteHistory> createState() => _ProgressNoteHistoryState();
}

class _ProgressNoteHistoryState extends State<ProgressNoteHistory> {
  List<dynamic> progressNotes = [];
  int currentPage = 1;
  bool isLoading = false;
  String? filterDate;
  String? filterPatientName;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProgressNotes();
  }

  Future<void> _fetchProgressNotes() async {
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
      final uri = Uri.parse('$baseUrl/nota_de_evolucion/history')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          progressNotes = json.decode(response.body)['data'];
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
                _fetchProgressNotes();
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
                _fetchProgressNotes();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressNoteDetails(Map<String, dynamic> note) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: note.entries
          .where((entry) =>
              entry.key != 'id_nota_de_evolucion' &&
              entry.key != 'nss_paciente')
          .map((entry) {
        final key = entry.key.replaceAll('_', ' ').toLowerCase();
        final value = entry.key == 'fecha_hora'
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
        title: const Text("progress_note_history").tr(),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : progressNotes.isEmpty
                    ? Center(child: const Text("no_records_found").tr())
                    : ListView.builder(
                        itemCount: progressNotes.length,
                        itemBuilder: (context, index) {
                          final note = progressNotes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _buildProgressNoteDetails(note),
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
                    _fetchProgressNotes();
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                currentPage++;
              });
              _fetchProgressNotes();
            },
          ),
        ],
      ),
    );
  }
}
