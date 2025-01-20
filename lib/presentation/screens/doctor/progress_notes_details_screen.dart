import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProgressNotesScreen extends StatefulWidget {
  final String nssPaciente;

  const ProgressNotesScreen({super.key, required this.nssPaciente});

  @override
  ProgressNotesScreenState createState() => ProgressNotesScreenState();
}

class ProgressNotesScreenState extends State<ProgressNotesScreen> {
  List<dynamic> progressNotes = [];
  int currentPage = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProgressNotes();
  }

  Future<void> _fetchProgressNotes() async {
    final url = Uri.parse(
        '$baseUrl/nota_de_evolucion/patient/${widget.nssPaciente}?page=$currentPage');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          progressNotes = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      //print('erorr: $e');
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
        title: Text('Progress Notes'.tr()),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : progressNotes.isEmpty
              ? const Center(child: Text('No Progress Notes Found'))
              : ListView.builder(
                  itemCount: progressNotes.length,
                  itemBuilder: (context, index) {
                    final note = progressNotes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Oxygen Saturation: ${formatDecimal(note['saturacion_oxigeno'])}"
                                    .tr()),
                            Text(
                                "Temperature: ${formatDecimal(note['temperatura'])}"
                                    .tr()),
                            Text("Heart Rate: ${note['frecuencia_cardiaca']}"
                                .tr()),
                            Text(
                                "Respiratory Rate: ${note['frecuencia_respiratoria']}"
                                    .tr()),
                            Text("Systolic Pressure: ${note['ta_sistolica']}"
                                .tr()),
                            Text("Diastolic Pressure: ${note['ta_diastolica']}"
                                .tr()),
                            Text("Evolution: ${note['evolucion']}".tr()),
                            Text("Somatometry: ${note['somatometria']}".tr()),
                            Text(
                                "Physical Examination: ${note['exploracion_fisica']}"
                                    .tr()),
                            Text("Laboratory: ${note['laboratorio']}".tr()),
                            Text("Image: ${note['imagen']}".tr()),
                            Text("Diagnosis: ${note['diagnostico']}".tr()),
                            Text(
                                "Plan and Comments: ${note['plan_y_comentario']}"
                                    .tr()),
                            Text("Prognosis: ${note['pronostico']}".tr()),
                            Text("Note: ${note['nota']}".tr()),
                            Text("Culture Result: ${note['resultado_cultivo']}"
                                .tr()),
                            Text(
                                "Culture Request Date: ${formatDateTime(note['fecha_solicitud_cultivo'])}"
                                    .tr()),
                            Text(
                                "Nosocomial Infection: ${note['infeccion_nosocomial']}"
                                    .tr()),
                            Text(
                                "Intubation Date: ${formatDateTime(note['fecha_intubacion'])}"
                                    .tr()),
                            Text(
                                "Catheter Date: ${formatDateTime(note['fecha_cateter'])}"
                                    .tr()),
                            Text(
                                "Date and Time: ${formatDateTime(note['fecha_hora'])}"
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
                    _fetchProgressNotes();
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
              _fetchProgressNotes();
            },
          ),
        ],
      ),
    );
  }
}
