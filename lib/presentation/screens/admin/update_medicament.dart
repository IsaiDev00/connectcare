import 'dart:convert';

import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/core/models/medicamento.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:connectcare/presentation/widgets/selectable_calendar.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
  final List<String> medicamentTypes = ['Unidad', 'Volumen', 'Peso', 'Dosis'];
  String? selectedMedicament;
  List<String> medicamentList = [];
  TextEditingController amountController = TextEditingController();
  TextEditingController stockController = TextEditingController();

  DateTime? expirationDay;
  String? formattedDate;
  final _formKey = GlobalKey<FormState>();

  List<String> medicamentListTypes() {
    switch (selectedMedicamentType) {
      case 'Unidad':
        return [
          'Cápsula',
          'Tableta',
          'Gragea',
          'Píldora',
          'Supositorio',
          'Óvulo',
          'Parche'
        ];
      case 'Volumen':
        return [
          'Jarabe',
          'Suspensión',
          'Elixir',
          'Gotas',
          'Inyectable',
          'Aerosol'
        ];
      case 'Peso':
        return ['Crema', 'Pomada', 'Gel', 'Polvo'];
      case 'Dosis':
        return ['Nebulizador', 'Inhalador'];
      default:
        return [];
    }
  }

  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese la cantidad por presentación';
    }
    int valueInt = int.parse(value);
    switch (selectedMedicament) {
      case 'Cápsula':
      case 'Tableta':
      case 'Gragea':
      case 'Píldora':
        if (valueInt > 1000) {
          return 'La cantidad por presentación máxima es de 1000 unidades';
        }
        break;
      case 'Polvo':
        if (valueInt > 500) {
          return 'La cantidad por presentación máxima es de 500 gramos';
        }
        break;
      case 'Jarabe':
      case 'Suspensión':
        if (valueInt > 2000) {
          return 'La cantidad por presentación máxima es de 2000 ml';
        }
        break;
      case 'Elixir':
        if (valueInt > 1500) {
          return 'La cantidad por presentación máxima es de 1500 ml';
        }
        break;
      case 'Gotas':
        if (valueInt > 2000) {
          return 'La cantidad por presentación máxima es de 200 ml';
        }
        break;
      case 'Crema':
      case 'Pomada':
      case 'Gel':
        if (valueInt > 1000) {
          return 'La cantidad por presentación máxima es de 1000 gramos';
        }
        break;
      case 'Parche':
        if (valueInt > 300) {
          return 'La cantidad por presentación máxima es de 300 unidades';
        }
        break;
      case 'Aerosol':
        if (valueInt > 500) {
          return 'La cantidad por presentación máxima es de 500 ml';
        }
        break;
      case 'Nebulizador':
      case 'Inhalador':
        if (valueInt > 200) {
          return 'La cantidad por presentación máxima es de 200 dosis';
        }
        break;
      case 'Supositorio':
      case 'Óvulo':
        if (valueInt > 500) {
          return 'La cantidad por presentación máxima es de 500 unidades';
        }
        break;
      case 'Inyectable':
        if (valueInt > 1000) {
          return 'La cantidad por presentación máxima es de 1000 ml';
        }
        break;
      case 'Otro':
        return null;
      default:
        return 'undefined';
    }
    return null;
  }

  String dateView() {
    return formattedDate != null ? formattedDate! : '';
  }

  @override
  void initState() {
    _loadClues();
    setMedicamentList();
    super.initState();
  }

  Future<void> _loadClues() async {
    final data = await _sharedPreferencesService.getClues();
    _clues = data ?? '';
  }

  Future<void> medicamentInit() async {
    var url = Uri.parse('$baseUrl/medicamento/${widget.id}');
    var response = await http.get(url);
    final Map data = json.decode(response.body);
    setState(() {
      nameController.text = data['nombre'];
      brandController.text = data['marca'];
      concentrationController.text = data['concentracion'];
      medicamentList = ['${data['tipo']}'];
      selectedMedicament = data['tipo'];
      formattedDate = data['caducidad'];
      amountController.text = data['cantidad_presentacion'].toString();
      stockController.text = data['cantidad_stock'].toString();
    });
    setState(() {
      selectedMedicamentType = lookForType();
    });
  }

  String lookForType() {
    switch (selectedMedicament) {
      case 'Cápsula':
      case 'Tableta':
      case 'Gragea':
      case 'Píldora':
      case 'Parche':
      case 'Supositorio':
      case 'Óvulo':
        return 'Unidad';
      case 'Aerosol':
      case 'Gotas':
      case 'Inyectable':
      case 'Suspensión':
      case 'Jarabe':
      case 'Elixir':
        return 'Volumen';

      case 'Polvo':
      case 'Pomada':
      case 'Crema':
      case 'Gel':
        return 'Peso';

      case 'Inhalador':
      case 'Nebulizador':
        return 'Dosis';

      default:
        return '';
    }
  }

  void setMedicamentList() async {
    medicamentList = medicamentListTypes();
    setState(() {});
    await medicamentInit();
  }

  Future<void> updateMedicament(
      String nombre,
      String marca,
      String tipo,
      int cantidadPresentacion,
      String concentracion,
      int cantidadStock,
      String caducidad,
      String clues) async {
    final url = Uri.parse('$baseUrl/medicamento/${widget.id}');
    Medicamento medicamento = Medicamento(
        nombre: nombre,
        marca: marca,
        tipo: tipo,
        cantidadPresentacion: cantidadPresentacion,
        concentracion: concentracion,
        cantidadStock: cantidadStock,
        caducidad: caducidad,
        clues: clues);

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(medicamento.toMap()),
    );

    _responseHandlerPut(response);
  }

  _responseHandlerPut(response) {
    responseHandlerPut(response, context, 'Medicamento actualizado con exito',
        'Error al actualizar medicamento');
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar medicamento"),
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
              // Center the Column
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
                      decoration: const InputDecoration(
                        labelText: "Nombre del medicamento",
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el nombre del medicamento';
                        }
                        if (value.length > 25) {
                          return 'Maximo de 25 caracteres';
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
                      decoration: const InputDecoration(
                        labelText: "Marca del medicamento",
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese la marca del medicamento';
                        }
                        if (value.length > 25) {
                          return 'Maximo de 25 caracteres';
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
                      decoration: const InputDecoration(
                        labelText: "Cantidad por concentración del medicamento",
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese la cantidad por concentración del medicamento';
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
                      decoration: const InputDecoration(
                        labelText: 'Tipo de medicamento',
                        border: OutlineInputBorder(),
                      ),
                      items: medicamentTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
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
                          return 'Por favor selecciona un tipo de medicamento';
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
                      decoration: const InputDecoration(
                        labelText: 'Tipo de medicamento',
                        border: OutlineInputBorder(),
                      ),
                      items: medicamentList.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
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
                          return 'Por favor selecciona un tipo de medicamento';
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
                      decoration: const InputDecoration(
                        labelText: "Cantidad por presentación",
                        border: OutlineInputBorder(),
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
                                : 'Seleccionar fecha',
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
                      decoration: const InputDecoration(
                        labelText: "Unidades disponibles",
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese las unidades disponibles';
                        }
                        int valueInt = int.parse(value);
                        if (valueInt > 100) {
                          return 'Unidades disponibles maximo de 100';
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
                          Navigator.pop(context, 'created');
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
                    child: const Text("Aceptar cambios"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
