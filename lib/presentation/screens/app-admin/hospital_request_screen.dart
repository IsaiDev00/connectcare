import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // Para abrir la app de llamadas

class HospitalRequestScreen extends StatefulWidget {
  const HospitalRequestScreen({super.key});

  @override
  _HospitalRequestScreen createState() => _HospitalRequestScreen();
}

class _HospitalRequestScreen extends State<HospitalRequestScreen> {
  List<dynamic> hospitalRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHospitalRequests();
  }

  Future<void> fetchHospitalRequests() async {
    const String apiUrl = '$baseUrl/administrador/solicitudes';
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          hospitalRequests = json.decode(response.body);
          isLoading = false;
        });
      } else {
        hospitalRequests.clear();
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      showErrorDialog(
          'Unable to fetch requests. Please check your connection.');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'.tr()),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'.tr()),
            ),
          ],
        );
      },
    );
  }

  void showRequestDetails(Map<String, dynamic> request) {
    TextEditingController reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    request['link_imagen'],
                    height: 260,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    request['nombre_hospital'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('State: ${request['estado']}'),
                  Text('Municipality: ${request['municipio']}'),
                  Text('Neighborhood: ${request['colonia']}'),
                  Text('Postal Code: ${request['cp']}'),
                  Text('Street: ${request['calle']}'),
                  Text(
                    'Requester: ${request['nombre']} '
                    '${request['apellido_paterno']} '
                    '${request['apellido_materno']}',
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Contact phone: ${request['telefono_contacto'] ?? "Pending"}',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone),
                        onPressed: () async {
                          final phone = request['telefono_contacto'];
                          if (phone != null && phone.toString().isNotEmpty) {
                            final url = 'tel:$phone';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Cannot launch phone call')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      showReasonDialog('Accept', reasonController, request);
                    },
                    child: Text('Accept Request'.tr()),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      showReasonDialog('Deny', reasonController, request);
                    },
                    child: Text('Deny Request'.tr()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showReasonDialog(
    String action,
    TextEditingController reasonController,
    Map<String, dynamic> request,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$action Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                // Recopilar datos para la solicitud POST
                final mensaje = reasonController.text.isNotEmpty
                    ? reasonController.text
                    : null;
                final aceptadaDenegada = (action == 'Accept') ? 1 : 0;
                final clues = request['clues'];
                final usuario = request['id_usuario'];
                final fecha = DateTime.now()
                    .toIso8601String()
                    .split('T')[0]; // YYYY-MM-DD

                // 1. Enviar la aceptación/denegación al backend
                final responseUrl =
                    Uri.parse('$baseUrl/administrador/hospitalResponse');
                final responseBody = json.encode({
                  'mensaje': mensaje,
                  'aceptada_denegada': aceptadaDenegada,
                  'clues': clues,
                  'usuario': usuario,
                  'fecha': fecha,
                });

                try {
                  final response = await http.post(
                    responseUrl,
                    headers: {'Content-Type': 'application/json'},
                    body: responseBody,
                  );

                  if (response.statusCode == 201) {
                    print('Registro creado exitosamente.');

                    // 2. Generar la notificación según sea aceptada o denegada
                    String notificationTitle;
                    String notificationBody;

                    if (aceptadaDenegada == 1) {
                      notificationTitle = 'Your apply has been accepted';
                      notificationBody = (mensaje != null &&
                              mensaje.trim().isNotEmpty)
                          ? mensaje
                          : 'Congrats';
                    } else {
                      notificationTitle = 'Your apply has been denied';
                      notificationBody = (mensaje != null &&
                              mensaje.trim().isNotEmpty)
                          ? mensaje
                          : 'We had doubts on your request';
                    }

                    final notificationUrl = Uri.parse(
                      '$baseUrl/firebase_notification/send-notification',
                    );
                    final notificationBodyJson = json.encode({
                      'userId': usuario,        // ID del solicitante
                      'title': notificationTitle,
                      'body': notificationBody,
                    });

                    try {
                      final notifResponse = await http.post(
                        notificationUrl,
                        headers: {'Content-Type': 'application/json'},
                        body: notificationBodyJson,
                      );

                      if (notifResponse.statusCode == 200 ||
                          notifResponse.statusCode == 201) {
                        print('Notificación enviada exitosamente.');
                      } else {
                        print(
                            'Error al enviar la notificación: ${notifResponse.body}');
                      }
                    } catch (e) {
                      print('Error de conexión al enviar notificación: $e');
                    }
                  } else {
                    print('Error al crear el registro: ${response.body}');
                  }
                } catch (e) {
                  print('Error de conexión: $e');
                }

                // Cerrar el AlertDialog
                Navigator.pop(context);
                // Cerrar el BottomSheet
                Navigator.pop(context);

                // Actualizar la lista de solicitudes
                if (mounted) {
                  await fetchHospitalRequests();
                }
              },
              child: Text('Submit'.tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospital Requests'.tr()),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hospitalRequests.isEmpty
              ? const Center(
                  child: Text(
                    'No more applications',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: hospitalRequests.length,
                  itemBuilder: (context, index) {
                    final request = hospitalRequests[index];
                    return ListTile(
                      title: Text(request['nombre_hospital']),
                      subtitle: Text(
                        '${request['nombre']} '
                        '${request['apellido_paterno']} - '
                        '${request['estado']}, ${request['municipio']}',
                      ),
                      onTap: () => showRequestDetails(request),
                    );
                  },
                ),
    );
  }
}
