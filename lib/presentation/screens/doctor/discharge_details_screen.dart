import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DischargeDetailsScreen extends StatefulWidget {
  final String nssPaciente;

  const DischargeDetailsScreen({super.key, required this.nssPaciente});

  @override
  DischargeDetailsScreenState createState() => DischargeDetailsScreenState();
}

class DischargeDetailsScreenState extends State<DischargeDetailsScreen> {
  List<dynamic> dischargeRecords = [];
  int currentPage = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDischargeRecords();
  }

  Future<void> _fetchDischargeRecords() async {
    final url = Uri.parse(
        '$baseUrl/paciente/patient/${widget.nssPaciente}?page=$currentPage');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          dischargeRecords = json.decode(response.body);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discharge Details'.tr()),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : dischargeRecords.isEmpty
              ? Center(child: Text('No discharge records found.'.tr()))
              : ListView.builder(
                  itemCount: dischargeRecords.length,
                  itemBuilder: (context, index) {
                    final record = dischargeRecords[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Discharge Date: {}'.tr(
                                  args: [formatDate(record['discharge_date'])]),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text('Discharge Reason: {}'
                                .tr(args: [record['discharge_reason']])),
                            Text(
                                'Doctor: {}'.tr(args: [record['doctor_name']])),
                            Text('Doctor ID: {}'
                                .tr(args: [record['id_personal'].toString()])),
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
            icon: Icon(Icons.arrow_back),
            onPressed: currentPage > 1
                ? () {
                    setState(() {
                      currentPage--;
                      isLoading = true;
                    });
                    _fetchDischargeRecords();
                  }
                : null,
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                currentPage++;
                isLoading = true;
              });
              _fetchDischargeRecords();
            },
          ),
        ],
      ),
    );
  }
}
