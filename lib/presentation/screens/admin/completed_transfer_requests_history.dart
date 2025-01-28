import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CompletedTransferRequestsHistory extends StatefulWidget {
  final String hospitalId;

  const CompletedTransferRequestsHistory({required this.hospitalId, super.key});

  @override
  CompletedTransferRequestsHistoryState createState() =>
      CompletedTransferRequestsHistoryState();
}

class CompletedTransferRequestsHistoryState
    extends State<CompletedTransferRequestsHistory> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  int _currentPage = 1;
  int _totalPages = 1;
  List<dynamic> _transferRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchTransferRequests();
  }

  Future<void> _fetchTransferRequests() async {
    final String baseUrl2 = '$baseUrl/paciente/history';
    final String date = _dateController.text;
    final String name = _nameController.text;

    final Uri url = Uri.parse(
        '$baseUrl2?hospitalId=${widget.hospitalId}&page=$_currentPage&fecha=$date&nombrePaciente=$name');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _transferRequests = data['data'];
          _currentPage = data['currentPage'];
          _totalPages = data['totalPages'];
        });
      } else {
        _showError('Failed to fetch transfer requests');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Transfer Requests'.tr()),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date (yyyy-MM-dd)',
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _dateController.text = _dateFormat.format(picked);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Patient Name',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _fetchTransferRequests,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _transferRequests.length,
              itemBuilder: (context, index) {
                final request = _transferRequests[index];
                return Card(
                  child: ListTile(
                    title: Text('Patient: ${request['paciente_nombre']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Camillero: ${request['camillero_nombre_completo']}'),
                        Text('Medico: ${request['medico_nombre_completo']}'),
                        Text('Date: ${request['fecha']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_totalPages > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() {
                            _currentPage--;
                          });
                          _fetchTransferRequests();
                        }
                      : null,
                  child: Text('Previous'.tr()),
                ),
                Text('Page $_currentPage of $_totalPages'),
                TextButton(
                  onPressed: _currentPage < _totalPages
                      ? () {
                          setState(() {
                            _currentPage++;
                          });
                          _fetchTransferRequests();
                        }
                      : null,
                  child: Text('Next'.tr()),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
