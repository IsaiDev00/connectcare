import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TriageDetailsScreen extends StatefulWidget {
  final String nssPaciente;

  const TriageDetailsScreen({super.key, required this.nssPaciente});

  @override
  TriageDetailsScreenState createState() => TriageDetailsScreenState();
}

class TriageDetailsScreenState extends State<TriageDetailsScreen> {
  List<dynamic> triageRecords = [];
  int currentPage = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTriageRecords();
  }

  Future<void> _fetchTriageRecords() async {
    final url = Uri.parse(
        '$baseUrl/triage/patient/${widget.nssPaciente}?page=$currentPage');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          triageRecords = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      //print('error: $e');
    }
  }

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('yyyy-MM-dd – kk:mm').format(parsedDate);
  }

  String formatDecimal(dynamic value) {
    if (value == null) {
      return 'N/A';
    }
    try {
      return double.parse(value.toString()).toStringAsFixed(2);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Triage Details').tr(),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : triageRecords.isEmpty
              ? Center(child: Text('No Triage Records Found').tr())
              : ListView.builder(
                  itemCount: triageRecords.length,
                  itemBuilder: (context, index) {
                    final triage = triageRecords[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Diagnosis: {}'.tr(args: [triage['diagnostico']]),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text('Treatment: {}'
                                .tr(args: [triage['tratamiento']])),
                            Text('Capillary Glucose: {}'.tr(
                                args: [formatDecimal(triage['g_capilar'])])),
                            Text('Respiratory Rate: {} bpm'.tr(args: [
                              triage['frecuencia_respiratoria'].toString()
                            ])),
                            Text('Heart Rate: {} bpm'.tr(args: [
                              triage['frecuencia_cardiaca'].toString()
                            ])),
                            Text(
                              'Blood Pressure: {}/{} mmHg'.tr(args: [
                                triage['ta_sistolica'].toString(),
                                triage['ta_diastolica'].toString()
                              ]),
                            ),
                            Text('Temperature: {}°C'
                                .tr(args: [triage['temperatura'].toString()])),
                            Text('Weight: {} kg'
                                .tr(args: [triage['peso'].toString()])),
                            Text('Height: {} cm'
                                .tr(args: [triage['estatura'].toString()])),
                            Text('Glasgow Scale: {}'.tr(
                                args: [triage['escala_glasgow'].toString()])),
                            Text('Severity: {}'.tr(args: [triage['gravedad']])),
                            Text('Reason: {}'.tr(args: [triage['motivo']])),
                            Text('Interrogation: {}'
                                .tr(args: [triage['interrogatorio']])),
                            Text('Physical Examination: {}'
                                .tr(args: [triage['exploracion_fisica']])),
                            Text('Auxiliary Diagnostics: {}'
                                .tr(args: [triage['auxiliares_diagnostico']])),
                            Text('Start Date: {}'.tr(
                                args: [formatDate(triage['fecha_inicio'])])),
                            Text('Start Time: {}'
                                .tr(args: [triage['hora_inicio']])),
                            Text('End Date: {}'
                                .tr(args: [formatDate(triage['fecha_fin'])])),
                            Text('End Time: {}'.tr(args: [triage['hora_fin']])),
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
                    _fetchTriageRecords();
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
              _fetchTriageRecords();
            },
          ),
        ],
      ),
    );
  }
}
