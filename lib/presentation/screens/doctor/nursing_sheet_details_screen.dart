import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NursingSheetDetailsScreen extends StatefulWidget {
  final String nssPaciente;

  const NursingSheetDetailsScreen({super.key, required this.nssPaciente});

  @override
  NursingSheetDetailsScreenState createState() =>
      NursingSheetDetailsScreenState();
}

class NursingSheetDetailsScreenState extends State<NursingSheetDetailsScreen> {
  List<dynamic> nursingRecords = [];
  int currentPage = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNursingRecords();
  }

  Future<void> _fetchNursingRecords() async {
    final url = Uri.parse(
        '$baseUrl/hoja_de_enfermeria/patient/${widget.nssPaciente}?page=$currentPage');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          nursingRecords = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      //print('error: $e');
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
        title: Text('Nursing Sheet Details'.tr()),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : nursingRecords.isEmpty
              ? Center(child: Text('No Nursing Sheets Found'.tr()))
              : ListView.builder(
                  itemCount: nursingRecords.length,
                  itemBuilder: (context, index) {
                    final record = nursingRecords[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: {}'
                                .tr(args: [formatDateTime(record['fecha'])])),
                            Text('Temperature Code: {}'
                                .tr(args: [record['codigo_temperatura']])),
                            Text('Interdependent Problem: {}'.tr(
                                args: [record['problema_interdependiente']])),
                            Text('Systolic Pressure: {} mmHg'
                                .tr(args: [record['ta_sistolica'].toString()])),
                            Text('Diastolic Pressure: {} mmHg'.tr(
                                args: [record['ta_diastolica'].toString()])),
                            Text('Respiratory Rate: {} bpm'.tr(args: [
                              record['frecuencia_respiratoria'].toString()
                            ])),
                            Text('Heart Rate: {} bpm'.tr(args: [
                              record['frecuencia_cardiaca'].toString()
                            ])),
                            Text('Internal Temperature: {}°C'.tr(args: [
                              formatDecimal(record['temperatura_interna'])
                            ])),
                            Text('PVC: {}'
                                .tr(args: [formatDecimal(record['pvc'])])),
                            Text('Perimeter: {}'.tr(
                                args: [formatDecimal(record['perimetro'])])),
                            Text('PF: {}'
                                .tr(args: [formatDecimal(record['pf'])])),
                            Text('Weight: {} kg'
                                .tr(args: [formatDecimal(record['peso'])])),
                            Text('Collaboration Interventions: {}'.tr(
                                args: [record['intervenciones_colaboracion']])),
                            Text('Medical Diagnosis: {}'
                                .tr(args: [record['dx_medico']])),
                            Text(
                                'Allergies: {}'.tr(args: [record['alergias']])),
                            Text('Height: {} cm'
                                .tr(args: [formatDecimal(record['estatura'])])),
                            Text('Total Incomes: {} ml'.tr(args: [
                              formatDecimal(record['total_ingresos'])
                            ])),
                            Text('Total Egress: {} ml'.tr(args: [
                              formatDecimal(record['total_egresos'])
                            ])),
                            Text('Total Balance: {} ml'.tr(args: [
                              formatDecimal(record['total_balance'])
                            ])),
                            Text('Oral Intake: {}'
                                .tr(args: [record['ing_oral']])),
                            Text('Catheter: {}'.tr(args: [record['sonda']])),
                            Text(
                                'Hemovigilance: {}'.tr(args: [record['hemo']])),
                            Text('Parenteral Nutrition: {}'
                                .tr(args: [record['nutri_par']])),
                            Text('Solution: {}'.tr(args: [record['solucion']])),
                            Text('Other Notes: {}'.tr(args: [record['otro']])),
                            Text('Urinary Output: {}'
                                .tr(args: [record['egresos_uresis']])),
                            Text('Evacuations: {}'
                                .tr(args: [record['evacuaciones']])),
                            Text('Hemorrhage: {}'
                                .tr(args: [record['hemorragia']])),
                            Text('Vomiting/Aspiration: {}'
                                .tr(args: [record['vom_asp']])),
                            Text('Drains: {}'.tr(args: [record['drenes']])),
                            Text('No Significant Changes: {}'
                                .tr(args: [record['sin_sig']])),
                            Text('Clinical Judgment: {}'
                                .tr(args: [record['juicio_clinico']])),
                            Text('Nursing Actions: {}'
                                .tr(args: [record['act_enfermeria']])),
                            Text('Evolution Response: {}'
                                .tr(args: [record['resp_evo']])),
                            Text('Observations: {}'.tr(args: [record['obs']])),
                            Text('Discharge Plan: {}'
                                .tr(args: [record['plan_egreso']])),
                            Text('Pain Assessment: {}'
                                .tr(args: [record['dolor_eva']])),
                            Text('Pressure Ulcer Risk: {}'
                                .tr(args: [record['riesgo_ulceras_pres']])),
                            Text('Fall Risk: {}'
                                .tr(args: [record['riesgo_caidas']])),
                            Text('State: {}'.tr(args: [record['estado']])),
                            Text('TC: {}'.tr(args: [record['TC'].toString()])),
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
                    _fetchNursingRecords();
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
              _fetchNursingRecords();
            },
          ),
        ],
      ),
    );
  }
}
