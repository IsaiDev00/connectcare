import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ViewDailyReport extends StatefulWidget {
  final DateTime date;
  const ViewDailyReport({required this.date, super.key});

  @override
  State<ViewDailyReport> createState() => _ViewDailyReportState();
}

class _ViewDailyReportState extends State<ViewDailyReport> {
  late String date;
  int index = 0;
  bool _isLoading = true;
  String loadingText = 'Loading';
  Timer? _timer;
  List<String> graphs = [];
  @override
  void initState() {
    super.initState();
    date = DateFormat('dd/MM/yy').format(widget.date);
    _startLoadingAnimation();

    _fetchGraphs();
  }

  _fetchGraphs() async {
    bool mov = await fetchGraphs();
    if (mov) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> fetchGraphs() async {
    // var url = Uri.parse('$baseUrl/auth/email/$email');
    var url = Uri.parse(
        'http://localhost:8080/generate_image/12/04/enfermeros,medicos,camilleros,trabajo_social,familiares,Hhoja_enfermeria,Hsolicitudes_traslado,Hindicaciones_medicas,Htriage,Hnotas_evolucion,Haltas_paciente,Htraslado_pacientes_completados,Htraslado_pacientes_no_completados,Hvinculaciones_cuentas_familiares,Hpeticiones_visita,Hpeticiones_visita_aceptadas,Hpeticiones_visita_no_aceptadas1');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      graphs = responseBody.images;
      return true;
    } else {
      return false;
    }
  }

  void _startLoadingAnimation() {
    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!_isLoading) {
        _timer?.cancel();
        return;
      }

      setState(() {
        switch (index) {
          case 0:
            loadingText = 'Loading';
            break;
          case 1:
            loadingText = 'Loading.';
            break;
          case 2:
            loadingText = 'Loading..';
            break;
          case 3:
            loadingText = 'Loading...';
            break;
        }
        index = (index + 1) % 4;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(date,
            style: theme.textTheme.titleMedium!.copyWith(
              color: theme.colorScheme.onSurface,
            )),
        centerTitle: true,
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Center(
                    child: Text(
                        '     $loadingText\nPlease wait for\nData Graphics',
                        style: theme.textTheme.headlineLarge!.copyWith(
                          color: theme.colorScheme.onSurface,
                        )),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: graphs.isNotEmpty
                        ? ListView.builder(
                            itemCount: graphs.length,
                            itemBuilder: (context, index) {
                              final item = graphs[index];
                              return ListTile(
                                  title: Image.network(
                                      'data:image/png;base64,$item'));
                            },
                          )
                        : Text('There was an error fetching graphs',
                            style: theme.textTheme.headlineLarge!.copyWith(
                              color: theme.colorScheme.onSurface,
                            )),
                  ),
                ],
              ),
      ),
    );
  }
}
