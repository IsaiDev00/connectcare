import 'dart:convert';

import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/core/models/medicamento.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:connectcare/presentation/widgets/selectable_calendar.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class UpdateMedicamentScreen extends StatefulWidget {
  final String id;
  const UpdateMedicamentScreen({required this.id, super.key});

  @override
  State<UpdateMedicamentScreen> createState() => _UpdateMedicamentScreenState();
}

class _UpdateMedicamentScreenState extends State<UpdateMedicamentScreen> {
  String _clues = '';
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();
  TextEditingController nameController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController concentrationController = TextEditingController();
  String? selectedMedicamentType;
  final List<Map<String, String>> medicamentTypes = [
    {'key': 'unit', 'value': tr('unit')},
    {'key': 'volume', 'value': tr('volume')},
    {'key': 'weight', 'value': tr('weight')},
    {'key': 'dose', 'value': tr('dose')},
  ];
  String? selectedMedicament;
  List<Map<String, String>> medicamentList = [];
  TextEditingController amountController = TextEditingController();
  TextEditingController stockController = TextEditingController();

  DateTime? expirationDay;
  String? formattedDate;
  final _formKey = GlobalKey<FormState>();

  List<Map<String, String>> medicamentListTypes() {
    switch (selectedMedicamentType) {
      case 'unit':
        return [
          {'key': 'capsule', 'value': tr('capsule')},
          {'key': 'tablet', 'value': tr('tablet')},
          {'key': 'dragee', 'value': tr('dragee')},
          {'key': 'pill', 'value': tr('pill')},
          {'key': 'suppository', 'value': tr('suppository')},
          {'key': 'ovule', 'value': tr('ovule')},
          {'key': 'patch', 'value': tr('patch')},
        ];
      case 'volume':
        return [
          {'key': 'syrup', 'value': tr('syrup')},
          {'key': 'suspension', 'value': tr('suspension')},
          {'key': 'elixir', 'value': tr('elixir')},
          {'key': 'drops', 'value': tr('drops')},
          {'key': 'injectable', 'value': tr('injectable')},
          {'key': 'aerosol', 'value': tr('aerosol')},
        ];
      case 'weight':
        return [
          {'key': 'cream', 'value': tr('cream')},
          {'key': 'ointment', 'value': tr('ointment')},
          {'key': 'gel', 'value': tr('gel')},
          {'key': 'powder', 'value': tr('powder')},
        ];
      case 'dose':
        return [
          {'key': 'nebulizer', 'value': tr('nebulizer')},
          {'key': 'inhaler', 'value': tr('inhaler')},
        ];
      default:
        return [];
    }
  }

  String lookForType(String? medicamentKey) {
    switch (medicamentKey) {
      case 'capsule':
      case 'tablet':
      case 'dragee':
      case 'pill':
      case 'patch':
      case 'suppository':
      case 'ovule':
        return 'unit';
      case 'aerosol':
      case 'drops':
      case 'injectable':
      case 'suspension':
      case 'syrup':
      case 'elixir':
        return 'volume';
      case 'powder':
      case 'ointment':
      case 'cream':
      case 'gel':
        return 'weight';
      case 'inhaler':
      case 'nebulizer':
        return 'dose';
      default:
        return '';
    }
  }

  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_presentation_quantity'.tr();
    }
    int valueInt = int.parse(value);
    switch (selectedMedicament) {
      case 'capsule':
      case 'tablet':
      case 'dragee':
      case 'pill':
        if (valueInt > 1000) {
          return 'max_unit_quantity'.tr();
        }
        break;
      case 'powder':
        if (valueInt > 500) {
          return 'max_weight_quantity'.tr();
        }
        break;
      case 'syrup':
      case 'suspension':
        if (valueInt > 2000) {
          return 'max_volume_quantity_2000'.tr();
        }
        break;
      case 'elixir':
        if (valueInt > 1500) {
          return 'max_volume_quantity_1500'.tr();
        }
        break;
      case 'drops':
        if (valueInt > 100) {
          return 'max_volume_quantity_100'.tr();
        }
        break;
      case 'cream':
      case 'ointment':
      case 'gel':
        if (valueInt > 1000) {
          return 'max_weight_quantity'.tr();
        }
        break;
      case 'patch':
        if (valueInt > 300) {
          return 'max_patch_quantity'.tr();
        }
        break;
      case 'aerosol':
        if (valueInt > 500) {
          return 'max_aerosol_quantity'.tr();
        }
        break;
      case 'nebulizer':
      case 'inhaler':
        if (valueInt > 200) {
          return 'max_dose_quantity'.tr();
        }
        break;
      case 'suppository':
      case 'ovule':
        if (valueInt > 500) {
          return 'max_suppository_quantity'.tr();
        }
        break;
      case 'injectable':
        if (valueInt > 1000) {
          return 'max_injectable_quantity'.tr();
        }
        break;
      default:
        return 'undefined'.tr();
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadClues();
    medicamentInit();
  }

  Future<void> _loadClues() async {
    final data = await _sharedPreferencesService.getClues();
    _clues = data ?? '';
  }

  void setMedicamentList() {
    medicamentList = medicamentListTypes();
    setState(() {});
  }

  Future<void> medicamentInit() async {
    var url = Uri.parse('$baseUrl/medicamento/${widget.id}');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        nameController.text = data['nombre'] ?? '';
        brandController.text = data['marca'] ?? '';
        concentrationController.text = data['concentracion'] ?? '';
        selectedMedicament = data['tipo'] ?? '';
        formattedDate = data['caducidad'] ?? '';
        amountController.text = data['cantidad_presentacion']?.toString() ?? '';
        stockController.text = data['cantidad_stock']?.toString() ?? '';

        selectedMedicamentType = lookForType(selectedMedicament);
        setMedicamentList();
      });
    } else {
      _errorLoadingMedicine();
    }
  }

  Future<void> updateMedicament(
    String nombre,
    String marca,
    String tipo,
    int cantidadPresentacion,
    String concentracion,
    int cantidadStock,
    String caducidad,
    String clues,
  ) async {
    final url = Uri.parse('$baseUrl/medicamento/${widget.id}');
    Medicamento medicamento = Medicamento(
      nombre: nombre,
      marca: marca,
      tipo: tipo,
      cantidadPresentacion: cantidadPresentacion,
      concentracion: concentracion,
      cantidadStock: cantidadStock,
      caducidad: caducidad,
      clues: clues,
    );

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(medicamento.toMap()),
    );

    _responseHandlerPut(response);
  }

  void _responseHandlerPut(response) {
    responseHandlerPut(
      response,
      context,
      'medicine_updated_successfully'.tr(),
      'error_updating_medicine'.tr(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: Text("edit_medicine".tr()),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:
              brightness == Brightness.dark ? Colors.transparent : Colors.white,
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: brightness == Brightness.dark
              ? Brightness.dark
              : Brightness.light,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 30),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    child: TextFormField(
                      controller: nameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: "medicine_name".tr(),
                        border: const OutlineInputBorder(),
                      ),
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_medicine_name'.tr();
                        }
                        if (value.length > 25) {
                          return 'max_characters'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    child: TextFormField(
                      controller: brandController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: "medicine_brand".tr(),
                        border: const OutlineInputBorder(),
                      ),
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_medicine_brand'.tr();
                        }
                        if (value.length > 25) {
                          return 'max_characters'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    child: TextFormField(
                      controller: concentrationController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: "medicine_concentration".tr(),
                        border: const OutlineInputBorder(),
                      ),
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_medicine_concentration'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    child: DropdownButtonFormField<String>(
                      value: selectedMedicamentType,
                      decoration: InputDecoration(
                        labelText: 'medicament_type'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      items: medicamentTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type['key'],
                          child: Text(
                            type['value']!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedMedicamentType = newValue;
                          selectedMedicament = null;
                          amountController.text = '';
                        });
                        setMedicamentList();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'select_medicine_type'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    child: DropdownButtonFormField<String>(
                      value: selectedMedicament,
                      decoration: InputDecoration(
                        labelText: 'medicament_specific_type'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      items: medicamentList.map((type) {
                        return DropdownMenuItem<String>(
                          value: type['key'],
                          child: Text(
                            type['value']!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedMedicament = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'select_specific_medicine_type'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    child: TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: "presentation_quantity".tr(),
                        border: const OutlineInputBorder(),
                      ),
                      autofocus: true,
                      onChanged: (value) {
                        setState(() {});
                      },
                      validator: (value) {
                        return validator(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: OutlinedButton(
                      onPressed: () async {
                        var response = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelectableCalendar(),
                          ),
                        );

                        if (response != null &&
                            response['selectedDate'] != null) {
                          expirationDay = response['selectedDate'];
                          formattedDate =
                              DateFormat('dd/MM/yyyy').format(expirationDay!);
                        }
                        setState(() {});
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 16),
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.8),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.surface,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedDate != null
                                ? formattedDate!
                                : 'select_expiration_date'.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 11,
                                ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.8),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    child: TextFormField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                          labelText: "available_units".tr(),
                          border: const OutlineInputBorder()),
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese las unidades disponibles'.tr();
                        }
                        int valueInt = int.parse(value);
                        if (valueInt > 100) {
                          return 'Unidades disponibles maximo de 100'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          formattedDate != null) {
                        nav() {
                          Navigator.pop(context, 'updated');
                        }

                        await updateMedicament(
                            nameController.text,
                            brandController.text,
                            selectedMedicament!,
                            int.parse(amountController.text),
                            concentrationController.text,
                            int.parse(stockController.text),
                            formattedDate!,
                            _clues);
                        nav();
                      }
                    },
                    child: Text("Aceptar cambios".tr()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _errorLoadingMedicine() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('error_loading_medicine'.tr())),
    );
  }
}
