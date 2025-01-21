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
  Map<String, int> counts = {};

  final List<Map<String, dynamic>> titlesWithIcons = [
    {
      "title": "Enfermeros",
      "icon": Icons.local_hospital,
      "keys": ["solicitudes_traslado_nurse", "hoja_enfermeria_nurse"]
    },
    {
      "title": "Médicos",
      "icon": Icons.person,
      "keys": [
        "solicitudes_traslado_doctor",
        "hoja_enfermeria_doctor",
        "indicaciones_medicas",
        "triage",
        "notas_evolucion",
        "altas_paciente"
      ]
    },
    {
      "title": "Camilleros",
      "icon": Icons.local_shipping,
      "keys": [
        "traslado_pacientes_completados",
        "traslado_pacientes_no_completados"
      ]
    },
    {
      "title": "Trabajo social",
      "icon": Icons.people,
      "keys": ["vinculaciones_cuentas_familiares"]
    },
  ];

  final List<Map<String, dynamic>> additionalTitlesWithIcons = [
    {
      "title": "Actualizaciones a hojas de enfermería",
      "icon": Icons.note_alt,
      "key": "hoja_enfermeria"
    },
    {
      "title": "Actualizaciones a indicaciones médicas",
      "icon": Icons.receipt,
      "key": "indicaciones_medicas"
    },
    {
      "title": "Actualizaciones a triage",
      "icon": Icons.assignment,
      "key": "triage"
    },
    {
      "title": "Actualizaciones a notas de evolución",
      "icon": Icons.edit_note,
      "key": "notas_evolucion"
    },
    {
      "title": "Altas de pacientes",
      "icon": Icons.exit_to_app,
      "key": "altas_paciente"
    },
    {
      "title": "Solicitudes de traslado generadas",
      "icon": Icons.send,
      "key": "solicitudes_traslado"
    },
    {
      "title": "Solicitudes de traslado completadas",
      "icon": Icons.done,
      "key": "traslado_pacientes_completados"
    },
    {
      "title": "Solicitudes de traslado no completadas",
      "icon": Icons.close,
      "key": "traslado_pacientes_no_completados"
    },
    {
      "title": "Vinculaciones de cuentas de familiares",
      "icon": Icons.family_restroom,
      "key": "vinculaciones_cuentas_familiares"
    },
  ];

  @override
  void initState() {
    super.initState();
    date = DateFormat('dd/MM/yy').format(widget.date);
    _startLoadingAnimation();
    _fetchGraphs();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchGraphs() async {
    var url = Uri.parse(
        'https://connectcare-graphics-320080170162.us-central1.run.app/generate_image/12/04/enfermeros,medicos,camilleros,trabajo_social,Hhoja_enfermeria,Hindicaciones_medicas,Htriage,Hnotas_evolucion,Haltas_paciente,Hsolicitudes_traslado,Htraslado_pacientes_completados,Htraslado_pacientes_no_completados,Hvinculaciones_cuentas_familiares');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      graphs = List<String>.from(responseBody['images']);
      counts = Map<String, int>.from(responseBody['counts']);
      setState(() {
        _isLoading = false;
      });
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
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          date,
          style: theme.textTheme.titleMedium,
        ),
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
                      style: theme.textTheme.headlineLarge,
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: graphs.length,
                itemBuilder: (context, index) {
                  if (index < titlesWithIcons.length) {
                    final title = titlesWithIcons[index];
                    final List<String> keys = title['keys'];
                    final List<String> stats = keys.map((key) {
                      if (key.contains("nurse")) {
                        return key == "solicitudes_traslado_nurse"
                            ? "Solicitudes de traslado por enfermeros: ${counts[key] ?? 0}"
                            : "Actualizaciones a hojas de enfermería por enfermeros: ${counts[key] ?? 0}";
                      } else if (key.contains("doctor")) {
                        return key == "solicitudes_traslado_doctor"
                            ? "Solicitudes de traslado por médicos: ${counts[key] ?? 0}"
                            : "Actualizaciones a hojas de enfermería por médicos: ${counts[key] ?? 0}";
                      } else if (key == "indicaciones_medicas") {
                        return "Indicaciones médicas generadas: ${counts[key] ?? 0}";
                      } else if (key == "triage") {
                        return "Triage generados: ${counts[key] ?? 0}";
                      } else if (key == "notas_evolucion") {
                        return "Notas de evolución generadas: ${counts[key] ?? 0}";
                      } else if (key == "altas_paciente") {
                        return "Pacientes dados de alta: ${counts[key] ?? 0}";
                      } else if (key == "traslado_pacientes_completados") {
                        return "Traslados de pacientes completados: ${counts[key] ?? 0}";
                      } else if (key == "traslado_pacientes_no_completados") {
                        return "Traslados de pacientes incompletos: ${counts[key] ?? 0}";
                      } else if (key == "vinculaciones_cuentas_familiares") {
                        return "Cuentas de familiares vinculadas: ${counts[key] ?? 0}";
                      }
                      return "";
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(
                                title['icon'],
                                size: 24,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                title['title'],
                                style: theme.textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        ),
                        ...stats.map(
                          (stat) => Padding(
                            padding:
                                const EdgeInsets.only(left: 40.0, bottom: 4.0),
                            child: Text(
                              stat,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        Card(
                          elevation: 4,
                          child: Image.memory(
                            base64Decode(graphs[index]),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    );
                  }

                  // Subtítulos y gráficas para categorías adicionales
                  final adjustedIndex = index - titlesWithIcons.length;
                  if (adjustedIndex >= 0 &&
                      adjustedIndex < additionalTitlesWithIcons.length) {
                    final title = additionalTitlesWithIcons[adjustedIndex];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(
                                title['icon'],
                                size: 24,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                title['title'],
                                style: theme.textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 40.0, bottom: 8.0),
                        ),
                        Card(
                          elevation: 4,
                          child: Image.memory(
                            base64Decode(graphs[index]),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox();
                },
              ),
      ),
    );
  }
}
