import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/user_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class FamilyLinkScreen extends StatefulWidget {
  const FamilyLinkScreen({super.key});

  @override
  FamilyLinkScreenState createState() => FamilyLinkScreenState();
}

class FamilyLinkScreenState extends State<FamilyLinkScreen> {
  TextEditingController codeController = TextEditingController();
  String userId = '';
  List<Map<String, dynamic>> linkedPatients = [];
  bool isCodeValid = true;
  String errorMessage = '';
  bool isLoadingPatients = true;

  @override
  void initState() {
    super.initState();

    codeController.addListener(() {
      final text = codeController.text.toUpperCase();
      if (codeController.text != text) {
        codeController.text = text;
        codeController.selection = TextSelection.fromPosition(
          TextPosition(offset: codeController.text.length),
        );
      }
    });

    _loadUserData();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService().loadUserData();

      setState(() {
        userId = userData['userId']?.trim() ?? '';
      });

      if (userId.isNotEmpty) {
        _fetchLinkedPatients();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data'.tr())),
        );
      }
    }
  }

  Future<void> _fetchLinkedPatients() async {
    setState(() {
      isLoadingPatients = true;
    });

    final url = Uri.parse('$baseUrl/family_link/linked-patients/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          linkedPatients = data
              .map((item) => {
                    'nss': item['nss'],
                    'nombre': item['nombre'],
                    'edad': item['edad'],
                  })
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching linked patients'.tr())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingPatients = false;
        });
      }
    }
  }

  Future<void> _validateCode() async {
    setState(() {
      isCodeValid = codeController.text.length == 8;
      errorMessage = isCodeValid
          ? ''
          : 'El código debe tener exactamente 8 caracteres'.tr();
    });

    if (!isCodeValid) return;

    final url = Uri.parse('$baseUrl/family_link/validate-code');
    try {
      final requestBody = {
        'code': codeController.text.trim(),
        'id_familiar': userId,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        setState(() {
          _fetchLinkedPatients();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Code validated successfully'.tr())),
          );
        }
      } else {
        String errorMessage = '';
        final responseBody = json.decode(response.body);

        if (responseBody.containsKey('message') &&
            responseBody['message'] != null) {
          if (responseBody['message'] ==
              'Ya existe un enlace entre este paciente y el familiar.') {
            errorMessage = 'existing link'.tr();
          } else {
            errorMessage = responseBody['message'].tr();
          }
        } else {
          errorMessage = 'Invalid or expired code'.tr();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error validating code'.tr())),
        );
      }
    }
  }

  Future<void> _unlinkPatient(String nssPaciente) async {
    final url = Uri.parse('$baseUrl/family_link/unlink-patient');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nss_paciente': nssPaciente, 'id_familiar': userId}),
      );

      if (response.statusCode == 200) {
        _fetchLinkedPatients();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Paciente desvinculado con éxito'.tr())),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al desvincular paciente'.tr())),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al desvincular paciente'.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Family Link'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Ingrese el código para vincular un paciente:".tr(),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  fontStyle: Theme.of(context).textTheme.bodyMedium?.fontStyle),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: codeController,
              maxLength: 8,
              decoration: InputDecoration(
                labelText: "Enter Code".tr(),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isCodeValid ? Colors.grey : Colors.red,
                  ),
                ),
                errorText: isCodeValid
                    ? null
                    : "El código debe tener exactamente 8 caracteres".tr(),
              ),
              keyboardType: TextInputType.visiblePassword,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _validateCode,
              child: Text("Validate Code".tr()),
            ),
            const SizedBox(height: 16),
            Text(
              "Pacientes vinculados:".tr(),
              style: TextStyle(
                  fontSize: 16,
                  fontStyle: Theme.of(context).textTheme.bodyMedium?.fontStyle),
            ),
            Expanded(
              child: isLoadingPatients
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : linkedPatients.isEmpty
                      ? Center(
                          child: Text(
                            "No hay pacientes vinculados.".tr(),
                            style: TextStyle(
                                fontSize: 14,
                                fontStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.fontStyle),
                          ),
                        )
                      : ListView.builder(
                          itemCount: linkedPatients.length,
                          itemBuilder: (context, index) {
                            final patient = linkedPatients[index];
                            return ListTile(
                              title: Text(patient['nombre'],
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              subtitle: Text("Edad:"
                                  .tr(args: [patient['edad'].toString()])),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Confirmar acción".tr()),
                                        content: Text(
                                            "¿Estás seguro de que quieres desvincularte de este paciente?"
                                                .tr()),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text("Cancelar".tr()),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _unlinkPatient(
                                                  patient['nss'].toString());
                                            },
                                            child: Text("Desvincular".tr()),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }
}
