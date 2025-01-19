import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PatientHistory extends StatelessWidget {
  final String nssPaciente;

  const PatientHistory({super.key, required this.nssPaciente});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Patient History')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Triage'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryDetailsScreen(
                  title: 'Triage',
                  endpoint: '/triage/patient/$nssPaciente',
                  itemsPerPage: 5,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text('Nursing Sheets'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryDetailsScreen(
                  title: 'Nursing Sheets',
                  endpoint: '/hoja_de_enfermeria/patient/$nssPaciente',
                  itemsPerPage: 5,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text('Progress Notes'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryDetailsScreen(
                  title: 'Progress Notes',
                  endpoint: '/nota_de_evolucion/patient/$nssPaciente',
                  itemsPerPage: 5,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text('Medical Instructions'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryDetailsScreen(
                  title: 'Medical Instructions',
                  endpoint: '/indicaciones_medicas/patient/$nssPaciente',
                  itemsPerPage: 5,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text('Discharge Records'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryDetailsScreen(
                  title: 'Discharge Records',
                  endpoint: '/paciente/patient/$nssPaciente',
                  itemsPerPage: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryDetailsScreen extends StatefulWidget {
  final String title;
  final String endpoint;
  final int itemsPerPage;

  const HistoryDetailsScreen(
      {super.key, required this.title,
      required this.endpoint,
      required this.itemsPerPage});

  @override
  _HistoryDetailsScreenState createState() => _HistoryDetailsScreenState();
}

class _HistoryDetailsScreenState extends State<HistoryDetailsScreen> {
  List<dynamic> records = [];
  int currentPage = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    final url = Uri.parse('$baseUrl${widget.endpoint}?page=$currentPage');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          records = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      //print('Error fetching records: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(records[index].toString()),
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
                    _fetchRecords();
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
              _fetchRecords();
            },
          ),
        ],
      ),
    );
  }
}
