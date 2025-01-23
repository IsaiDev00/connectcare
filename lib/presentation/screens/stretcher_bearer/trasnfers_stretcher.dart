import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TrasnfersStretcher extends StatefulWidget {
  const TrasnfersStretcher({super.key});

  @override
  _TrasnfersStretcherState createState() => _TrasnfersStretcherState();
}

class _TrasnfersStretcherState extends State<TrasnfersStretcher> {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  String? userId;
  List<dynamic> transfers = [];
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
    final url = Uri.parse('$baseUrl/traslado/camillero/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        // Filtrar solo los estados relevantes
        setState(() {
          transfers = results.where((t) {
            final est = t['estatus'];
            return est == 'Notificado' ||
                est == 'No encontrado' ||
                est == 'En curso' ||
                est == 'Terminado';
          }).toList();
          loading = false;
        });
      } else {
        setState(() {
          transfers = [];
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        transfers = [];
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

  Widget _buildActionButtons(dynamic traslado) {
    final estado = traslado['estatus'];
    if (estado == 'Notificado') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              // Cambiar estado a "En curso"
              final url = Uri.parse('$baseUrl/traslado/cambiarEstado');
              await http.post(
                url,
                body: json.encode({
                  'id_traslado': traslado['id_traslado'],
                  'estatus': 'En curso'
                }),
                headers: {'Content-Type': 'application/json'},
              );
              await _fetchTransfers();
            },
            child: const Text('Recogido'),
          ),
          const SizedBox(height: 4),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // Cambiar estado a "No encontrado"
              final url = Uri.parse('$baseUrl/traslado/cambiarEstado');
              await http.post(
                url,
                body: json.encode({
                  'id_traslado': traslado['id_traslado'],
                  'estatus': 'No encontrado'
                }),
                headers: {'Content-Type': 'application/json'},
              );
              await _fetchTransfers();
            },
            child: const Text('No encontrado'),
          ),
        ],
      );
    } else if (estado == 'En curso') {
      return ElevatedButton(
        onPressed: () async {
          final url = Uri.parse('$baseUrl/traslado/terminarTraslado');
          // Obtener la hora actual en formato "HH:mm:ss"
          final now = DateTime.now();
          final horaLlegada = "${now.hour.toString().padLeft(2, '0')}:"
              "${now.minute.toString().padLeft(2, '0')}:"
              "${now.second.toString().padLeft(2, '0')}";
          await http.post(
            url,
            body: json.encode({
              'id_traslado': traslado['id_traslado'],
              'id_cama': traslado['numero_cama'],
              'hora_llegada': horaLlegada
            }),
            headers: {'Content-Type': 'application/json'},
          );
          await _fetchTransfers();
        },
        child: const Text('Terminado'),
      );
    } else {
      // Para "No encontrado" que ya no muestra botones aquí y "Terminado" sin botones.
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransfers = _filterTransfers(transfers);
    return Scaffold(
      appBar: AppBar(title: const Text('Traslados Camillero')),
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
                    child: filteredTransfers.isEmpty
                        ? const Center(child: Text('No hay traslados.'))
                        : ListView.builder(
                            itemCount: filteredTransfers.length,
                            itemBuilder: (context, index) {
                              final traslado = filteredTransfers[index];
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
        ],
      ),
    );
  }
}
