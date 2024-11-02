import 'dart:convert';

import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/core/models/medicamento.dart';
import 'package:connectcare/presentation/widgets/selectable_calendar.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class CreateMedicamentScreen extends StatefulWidget {
  const CreateMedicamentScreen({super.key});

  @override
  State<CreateMedicamentScreen> createState() => _CreateMedicamentScreenState();
}

class _CreateMedicamentScreenState extends State<CreateMedicamentScreen> {
  int idAdministrador = 4;
  TextEditingController nameController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController concentrationController = TextEditingController();
  String? selectedMedicamentType;
  final List<String> medicamentTypes = ['Unidad', 'Volumen', 'Peso', 'Dosis'];
  String? selectedMedicament;
  List<String> medicamentList = [];
  TextEditingController amountController = TextEditingController();
  TextEditingController expirationDateController = TextEditingController();
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
    setMedicamentList();
    super.initState();
  }

  void setMedicamentList() {
    medicamentList = medicamentListTypes();
    setState(() {});
  }

  void agregarMedicamento(
      String nombre,
      String marca,
      String tipo,
      int cantidadPresentacion,
      String concentracion,
      int cantidadStock,
      String caducidad,
      int idAdministrador) async {
    final url = Uri.parse('$baseUrl/medicamento');
    Medicamento medicamento = Medicamento(
        nombre: nombre,
        marca: marca,
        tipo: tipo,
        cantidadPresentacion: cantidadPresentacion,
        concentracion: concentracion,
        cantidadStock: cantidadStock,
        caducidad: caducidad,
        idAdministrador: idAdministrador);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(medicamento.toMap()),
    );

    responseHandler(response);
  }

  void responseHandler(http.Response response) {
    if (response.statusCode == 201) {
      showCustomSnackBar(context, 'Medicamento creado con exito');
    } else {
      showCustomSnackBar(context, 'Error al crear medicamento');
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear medicamento"),
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
                    width: MediaQuery.of(context).size.width / 2,
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
                    width: MediaQuery.of(context).size.width / 2,
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
                    width: MediaQuery.of(context).size.width / 2,
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
                    width: MediaQuery.of(context).size.width / 2,
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
                    width: MediaQuery.of(context).size.width / 2,
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
                    width: MediaQuery.of(context).size.width / 2,
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
                    width: MediaQuery.of(context).size.width / 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ElevatedButton(
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          textStyle: const TextStyle(fontSize: 14),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                            'Seleccionar fecha de caducidad ${dateView()}'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
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
                        Navigator.pop(context);

                        agregarMedicamento(
                            nameController.text,
                            brandController.text,
                            selectedMedicament!,
                            int.parse(amountController.text),
                            concentrationController.text,
                            int.parse(stockController.text),
                            formattedDate!,
                            idAdministrador);
                      }
                    },
                    child: const Text("Crear medicamento"),
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
