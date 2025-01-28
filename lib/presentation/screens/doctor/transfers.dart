import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Transfers extends StatefulWidget {
  const Transfers({super.key});

  @override
  _TransfersState createState() => _TransfersState();
}

class _TransfersState extends State<Transfers> {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  String? userId;
  List<dynamic> activeTransfers = [];
  List<dynamic> archivedTransfers = [];
  bool loading = true;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initUserAndFetchTransfers();
  }

  void _initUserAndFetchTransfers() async {
    userId = await _sharedPreferencesService.getUserId();
    await _fetchTransfers();
  }

  Future<void> _fetchTransfers() async {
    if (userId == null) return;
    final url = Uri.parse('$baseUrl/traslado/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        setState(() {
          activeTransfers = results.where((t) => t['archivado'] == 0).toList();
          archivedTransfers =
              results.where((t) => t['archivado'] == 1).toList();
          loading = false;
        });
      } else {
        setState(() {
          activeTransfers = [];
          archivedTransfers = [];
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        activeTransfers = [];
        archivedTransfers = [];
        loading = false;
      });
    }
  }

  List<dynamic> _filterTransfers(List<dynamic> transfers) {
    if (searchQuery.isEmpty) return transfers;
    return transfers.where((t) {
      final nss = t['nss_paciente'].toString();
      return nss.contains(searchQuery);
    }).toList();
  }

  void _showArchivedTransfers() {
    showDialog(
      context: context,
      builder: (context) {
        final filteredArchived = _filterTransfers(archivedTransfers);
        return AlertDialog(
          title: Text('Traslados Archivados'.tr()),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration:
                      const InputDecoration(labelText: 'Buscar por NSS'),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: filteredArchived.isEmpty
                      ? const Center(
                          child: Text('No hay traslados archivados.'))
                      : ListView.builder(
                          itemCount: filteredArchived.length,
                          itemBuilder: (context, index) {
                            final traslado = filteredArchived[index];
                            return Container(
                              padding: const EdgeInsets.all(8.0),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Fecha: ${traslado['fecha'].split('T')[0]}'),
                                  SizedBox(height: 4),
                                  Text(
                                      'Hora Programada: ${traslado['hora_programada']}'),
                                  SizedBox(height: 2),
                                  Text('NSS: ${traslado['nss_paciente']}'),
                                  SizedBox(height: 2),
                                  Text('Cama ID: ${traslado['numero_cama']}'),
                                  SizedBox(height: 2),
                                  Text('Estatus: ${traslado['estatus']}'),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          final url = Uri.parse(
                                              '$baseUrl/traslado/archivar');
                                          await http.post(
                                            url,
                                            body: json.encode({
                                              'id_traslado':
                                                  traslado['id_traslado'],
                                              'archivado':
                                                  0 // Enviado como entero
                                            }),
                                            headers: {
                                              'Content-Type': 'application/json'
                                            },
                                          );
                                          await _fetchTransfers();
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue),
                                        child: Text('Desarchivar'.tr()),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Atrás'.tr()),
            )
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(dynamic traslado) {
    final estado = traslado['estatus'];
    if (estado == 'Terminado') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              final url = Uri.parse('$baseUrl/traslado/confirmarTraslado');
              await http.post(
                url,
                body: json.encode({'id_traslado': traslado['id_traslado']}),
                headers: {'Content-Type': 'application/json'},
              );
              await _fetchTransfers();
            },
            child: Text('Confirmar'.tr()),
          ),
          const SizedBox(height: 4),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final url = Uri.parse('$baseUrl/traslado/denegarTraslado');
              await http.post(
                url,
                body: json.encode({'id_traslado': traslado['id_traslado']}),
                headers: {'Content-Type': 'application/json'},
              );
              await _fetchTransfers();
            },
            child: Text('Denegar'.tr()),
          ),
        ],
      );
    } else if (estado == 'Cancelado') {
      return ElevatedButton(
        onPressed: () async {
          final url = Uri.parse('$baseUrl/traslado/archivar');
          await http.post(
            url,
            body: json.encode(
                {'id_traslado': traslado['id_traslado'], 'archivado': 1}),
            headers: {'Content-Type': 'application/json'},
          );
          await _fetchTransfers();
        },
        child: Text('Archivar'.tr()),
      );
    } else if (estado == 'Confirmado') {
      return ElevatedButton(
        onPressed: () async {
          final url = Uri.parse('$baseUrl/traslado/archivar');
          await http.post(
            url,
            body: json.encode(
                {'id_traslado': traslado['id_traslado'], 'archivado': 1}),
            headers: {'Content-Type': 'application/json'},
          );
          await _fetchTransfers();
        },
        child: Text('Archivar'.tr()),
      );
    } else if (estado == 'Esperando' ||
        estado == 'Pospuesto' ||
        estado == 'Notificado') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final url = Uri.parse('$baseUrl/traslado/cambiarEstado');
              await http.post(
                url,
                body: json.encode({
                  'id_traslado': traslado['id_traslado'],
                  'estatus': 'Cancelado'
                }),
                headers: {'Content-Type': 'application/json'},
              );
              await _fetchTransfers();
            },
            child: Text('Cancelar'.tr()),
          ),
          const SizedBox(width: 4),
          if (estado == 'No encontrado')
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                _showPosponerDialog(traslado['id_traslado']);
              },
              child: Text('Posponer'.tr()),
            ),
        ],
      );
    } else if (estado == 'En curso') {
      return const SizedBox();
    } else if (estado == 'No encontrado') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final url = Uri.parse('$baseUrl/traslado/cambiarEstado');
              await http.post(
                url,
                body: json.encode({
                  'id_traslado': traslado['id_traslado'],
                  'estatus': 'Cancelado'
                }),
                headers: {'Content-Type': 'application/json'},
              );
              await _fetchTransfers();
            },
            child: Text('Cancelar'.tr()),
          ),
          const SizedBox(height: 4),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              _showPosponerDialog(traslado['id_traslado']);
            },
            child: Text('Posponer'.tr()),
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  void _showPosponerDialog(dynamic idTraslado) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Posponer traslado'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final minutos in [5, 10, 15, 20, 30])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      final url =
                          Uri.parse('$baseUrl/traslado/posponerTraslado');
                      await http.post(
                        url,
                        body: json.encode(
                            {'id_traslado': idTraslado, 'minutos': minutos}),
                        headers: {'Content-Type': 'application/json'},
                      );
                      Navigator.of(context).pop();
                      await _fetchTransfers();
                    },
                    child: Text('$minutos min'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(30),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'.tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredActive = _filterTransfers(activeTransfers);
    return Scaffold(
      appBar: AppBar(title: Text('Traslados'.tr())),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(labelText: 'Buscar por NSS'),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchTransfers,
                    child: filteredActive.isEmpty
                        ? const Center(child: Text('No hay traslados activos.'))
                        : ListView.builder(
                            itemCount: filteredActive.length,
                            itemBuilder: (context, index) {
                              final traslado = filteredActive[index];
                              return Container(
                                padding: const EdgeInsets.all(8.0),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Fecha: ${traslado['fecha'].split('T')[0]}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                              'Hora Programada: ${traslado['hora_programada']}'),
                                          const SizedBox(height: 2),
                                          Text(
                                              'NSS: ${traslado['nss_paciente']}'),
                                          const SizedBox(height: 2),
                                          Text(
                                              'Cama ID: ${traslado['numero_cama']}'),
                                          const SizedBox(height: 2),
                                          Text(
                                              'Estatus: ${traslado['estatus'] == 'Terminado' ? 'Esperando confirmación de remitente' : traslado['estatus']}'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildActionButtons(traslado),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _showArchivedTransfers,
            child: Text('Mostrar archivadas'.tr()),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
