import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Modelo para Medicamento
class Medicamento {
  final int id;
  final String nombre;
  final String marca;
  final String tipo;
  final int cantidadPresentacion;
  final String concentracion;
  final int cantidadStock;
  final String caducidad;
  final int idAdministrador;

  Medicamento({
    required this.id,
    required this.nombre,
    required this.marca,
    required this.tipo,
    required this.cantidadPresentacion,
    required this.concentracion,
    required this.cantidadStock,
    required this.caducidad,
    required this.idAdministrador,
  });

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento(
      id: json['id_medicamento'],
      nombre: json['nombre'],
      marca: json['marca'],
      tipo: json['tipo'],
      cantidadPresentacion: json['cantidad_presentacion'],
      concentracion: json['concentracion'],
      cantidadStock: json['cantidad_stock'],
      caducidad: json['caducidad'],
      idAdministrador: json['id_administrador'],
    );
  }
}

// Modelo para Medicamento Agregado
class AddedMedication {
  final Medicamento medicamento;
  final int cajas;

  AddedMedication({required this.medicamento, required this.cajas});
}

class HojaEnfermeriaScreen extends StatefulWidget {
  const HojaEnfermeriaScreen({super.key});

  @override
  _HojaEnfermeriaScreen createState() => _HojaEnfermeriaScreen();
}

class _HojaEnfermeriaScreen extends State<HojaEnfermeriaScreen> {
  final _formKey = GlobalKey<FormState>();
  // GENERAL INFORMATION
  final TextEditingController alergiasController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController estaturaController = TextEditingController();
  final TextEditingController perimetroController = TextEditingController();

  // MULTIPLE OPTIONS
  List<String> escala = ['A', 'M', 'B'];
  String? dolorEvaCon;
  String? riesgoUlcerasPresCon;
  String? riesgoCaidasCon;

  List<String> estadoOpciones = [
    'estable',
    'mejorando',
    'critico, pero estable',
    'grave',
    'emergencia'
  ];
  String? estado;

  List<String> codigoTempOpciones = ['FR', 'AX', 'OR', 'RE'];
  String? codigoTemp;

  // UP TO 10 FIELDS
  // VITAL SIGNS
  List<TextEditingController> fcControllers = [];
  List<TextEditingController> tiControllers = [];
  List<TextEditingController> tcControllers = [];
  List<TextEditingController> tasControllers = [];
  List<TextEditingController> tadControllers = [];
  List<TextEditingController> pvcControllers = [];
  List<TextEditingController> frecRespiratoriaControllers = [];

  // UP TO 5 FIELDS
  // INTRAVENOUS INFUSION
  List<TextEditingController> formulaControllers = [];
  List<TextEditingController> dietaControllers = [];
  List<TextEditingController> liqOralesControllers = [];

  // MEDICATIONS
  List<AddedMedication> addedMedicamentos = [];

  // Lista de medicamentos obtenidos de la BD
  List<Medicamento> medicamentosList = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with one field
    fcControllers.add(TextEditingController());
    tiControllers.add(TextEditingController());
    tcControllers.add(TextEditingController());
    tasControllers.add(TextEditingController());
    tadControllers.add(TextEditingController());
    pvcControllers.add(TextEditingController());
    frecRespiratoriaControllers.add(TextEditingController());

    formulaControllers.add(TextEditingController());
    dietaControllers.add(TextEditingController());
    liqOralesControllers.add(TextEditingController());

    // Inicializar con un medicamento agregado por defecto si es necesario
    // addedMedicamentos.add(AddedMedication(medicamento: medicamentosList[0], cajas: 1));
  }

  // Funciones para agregar campos
  void addFcField() {
    if (fcControllers.length < 10) {
      setState(() {
        fcControllers.add(TextEditingController());
      });
    }
  }

  void addTiField() {
    if (tiControllers.length < 10) {
      setState(() {
        tiControllers.add(TextEditingController());
      });
    }
  }

  void addTcField() {
    if (tcControllers.length < 10) {
      setState(() {
        tcControllers.add(TextEditingController());
      });
    }
  }

  void addTasField() {
    if (tasControllers.length < 10) {
      setState(() {
        tasControllers.add(TextEditingController());
      });
    }
  }

  void addTadField() {
    if (tadControllers.length < 10) {
      setState(() {
        tadControllers.add(TextEditingController());
      });
    }
  }

  void addPvcField() {
    if (pvcControllers.length < 10) {
      setState(() {
        pvcControllers.add(TextEditingController());
      });
    }
  }

  void addFrecRespiratoriaField() {
    if (frecRespiratoriaControllers.length < 10) {
      setState(() {
        frecRespiratoriaControllers.add(TextEditingController());
      });
    }
  }

  void addFormulaField() {
    if (formulaControllers.length < 5) {
      setState(() {
        formulaControllers.add(TextEditingController());
      });
    }
  }

  void addDietaField() {
    if (dietaControllers.length < 5) {
      setState(() {
        dietaControllers.add(TextEditingController());
      });
    }
  }

  void addLiqOralesField() {
    if (liqOralesControllers.length < 5) {
      setState(() {
        liqOralesControllers.add(TextEditingController());
      });
    }
  }

  // Funciones para eliminar campos
  void removeFcField() {
    if (fcControllers.length > 1) {
      setState(() {
        fcControllers.last.dispose();
        fcControllers.removeLast();
      });
    }
  }

  void removeTiField() {
    if (tiControllers.length > 1) {
      setState(() {
        tiControllers.last.dispose();
        tiControllers.removeLast();
      });
    }
  }

  void removeTcField() {
    if (tcControllers.length > 1) {
      setState(() {
        tcControllers.last.dispose();
        tcControllers.removeLast();
      });
    }
  }

  void removeTasField() {
    if (tasControllers.length > 1) {
      setState(() {
        tasControllers.last.dispose();
        tasControllers.removeLast();
      });
    }
  }

  void removeTadField() {
    if (tadControllers.length > 1) {
      setState(() {
        tadControllers.last.dispose();
        tadControllers.removeLast();
      });
    }
  }

  void removePvcField() {
    if (pvcControllers.length > 1) {
      setState(() {
        pvcControllers.last.dispose();
        pvcControllers.removeLast();
      });
    }
  }

  void removeFrecRespiratoriaField() {
    if (frecRespiratoriaControllers.length > 1) {
      setState(() {
        frecRespiratoriaControllers.last.dispose();
        frecRespiratoriaControllers.removeLast();
      });
    }
  }

  void removeFormulaField() {
    if (formulaControllers.length > 1) {
      setState(() {
        formulaControllers.last.dispose();
        formulaControllers.removeLast();
      });
    }
  }

  void removeDietaField() {
    if (dietaControllers.length > 1) {
      setState(() {
        dietaControllers.last.dispose();
        dietaControllers.removeLast();
      });
    }
  }

  void removeLiqOralesField() {
    if (liqOralesControllers.length > 1) {
      setState(() {
        liqOralesControllers.last.dispose();
        liqOralesControllers.removeLast();
      });
    }
  }

  void removeMedicamentoField() async {
    if (addedMedicamentos.isNotEmpty) {
      final AddedMedication? removed = await showDialog<AddedMedication>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Eliminar Medicamento'),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: addedMedicamentos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(addedMedicamentos[index].medicamento.nombre),
                    subtitle: Text(
                        'Cantidad: ${addedMedicamentos[index].cajas} cajas'),
                    onTap: () {
                      Navigator.of(context).pop(addedMedicamentos[index]);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar'),
              ),
            ],
          );
        },
      );

      if (removed != null) {
        setState(() {
          addedMedicamentos.remove(removed);
        });
      }
    }
  }

// Función para abrir el dialogo de selección de medicamento
  void openAddMedicamentoDialog() async {
    try {
      List<Medicamento> medicamentos = await fetchMedicamentos();
      setState(() {
        medicamentosList = medicamentos;
      });
    } catch (e) {
      // Manejar errores de la API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar medicamentos')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        List<Medicamento> filteredMedicamentos = medicamentosList;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Seleccionar Medicamento'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      filteredMedicamentos = medicamentosList
                          .where((med) => med.nombre
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                ),
                SizedBox(height: 10),
                Container(
                  width: double.maxFinite,
                  height: 200,
                  child: ListView.builder(
                    itemCount: filteredMedicamentos.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredMedicamentos[index].nombre),
                        subtitle: Text(
                            '${filteredMedicamentos[index].tipo} - Stock: ${filteredMedicamentos[index].cantidadStock}'),
                        onTap: () async {
                          Navigator.of(context)
                              .pop(filteredMedicamentos[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    ).then((selectedMedicamento) async {
      if (selectedMedicamento != null) {
        // Mostrar dialogo para ingresar cantidad de cajas
        String? errorMessage;
        int? cajas = await showDialog<int>(
          context: context,
          builder: (context) {
            TextEditingController cajasController = TextEditingController();
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: Text('Cantidad de Cajas'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: cajasController,
                      decoration: InputDecoration(
                        labelText: 'Número de cajas',
                        border: OutlineInputBorder(),
                        errorText: errorMessage,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      int? value = int.tryParse(cajasController.text);
                      if (value == null || value <= 0) {
                        setState(() {
                          errorMessage = 'Ingrese una cantidad válida';
                        });
                        return;
                      }
                      if (value > selectedMedicamento.cantidadStock) {
                        setState(() {
                          errorMessage =
                              'No puede exceder el stock disponible (${selectedMedicamento.cantidadStock})';
                        });
                        return;
                      }
                      Navigator.of(context).pop(value);
                    },
                    child: Text('Agregar'),
                  ),
                ],
              );
            });
          },
        );

        if (cajas != null) {
          setState(() {
            addedMedicamentos.add(AddedMedication(
                medicamento: selectedMedicamento, cajas: cajas));
          });
        }
      }
    });
  }

  // Función para obtener medicamentos de la BD
  Future<List<Medicamento>> fetchMedicamentos() async {
    final response = await http.get(Uri.parse('$baseUrl/medicamento/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Medicamento.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar medicamentos');
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    alergiasController.dispose();
    pesoController.dispose();
    estaturaController.dispose();
    perimetroController.dispose();

    fcControllers.forEach((controller) => controller.dispose());
    tiControllers.forEach((controller) => controller.dispose());
    tcControllers.forEach((controller) => controller.dispose());
    tasControllers.forEach((controller) => controller.dispose());
    tadControllers.forEach((controller) => controller.dispose());
    pvcControllers.forEach((controller) => controller.dispose());
    frecRespiratoriaControllers.forEach((controller) => controller.dispose());

    formulaControllers.forEach((controller) => controller.dispose());
    dietaControllers.forEach((controller) => controller.dispose());
    liqOralesControllers.forEach((controller) => controller.dispose());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hoja de Enfermería'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                  child: const Text(
                "Información General",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              )),
              const SizedBox(height: 30),

              // ALERGIAS
              TextFormField(
                controller: alergiasController,
                decoration: InputDecoration(
                  labelText: 'Alergias',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                validator: (value) {
                  if ((value?.length ?? 0) > 100) {
                    return 'Debe tener menos de 100 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // PESO
              TextFormField(
                controller: pesoController,
                decoration: InputDecoration(
                  labelText: "Peso",
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el peso del paciente';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // ESTATURA
              TextFormField(
                controller: estaturaController,
                decoration: InputDecoration(
                  labelText: "Estatura",
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la estatura del paciente';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // PERÍMETRO
              TextFormField(
                controller: perimetroController,
                decoration: InputDecoration(
                  labelText: "Perímetro (cm)",
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un perímetro para el paciente en cm';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // ESTADO DEL PACIENTE
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Estado del Paciente",
                  border: OutlineInputBorder(),
                ),
                value: estado,
                items: estadoOpciones
                    .map((option) => DropdownMenuItem(
                          child: Text(option),
                          value: option,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    estado = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor elija una opción';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // CÓDIGO DE TEMPERATURA
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Código de Temperatura",
                  border: OutlineInputBorder(),
                ),
                value: codigoTemp,
                items: codigoTempOpciones
                    .map((option) => DropdownMenuItem(
                          child: Text(option),
                          value: option,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    codigoTemp = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor elija un código';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // SIGNOS VITALES
              Center(
                  child: const Text(
                "Signos Vitales",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              )),
              const SizedBox(height: 15),

              // FC (Frecuencia Cardíaca)
              Center(child: const Text("Frecuencia Cardíaca (FC)")),
              const SizedBox(height: 10),
              ...fcControllers.map((controller) {
                int index = fcControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "FC ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Por favor ingrese FC ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }).toList(),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addFcField,
                      child: Text("Agregar FC (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeFcField,
                      child: Text("Eliminar FC (-)"),
                    ),
                  ],
                ),
              ),

              // TI (Temperatura Ingerida)
              const SizedBox(height: 15),
              Center(child: const Text("Temperatura Ingerida (TI)")),
              const SizedBox(height: 10),
              ...tiControllers.map((controller) {
                int index = tiControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "TI ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Por favor ingrese TI ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }).toList(),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addTiField,
                      child: Text("Agregar TI (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeTiField,
                      child: Text("Eliminar TI (-)"),
                    ),
                  ],
                ),
              ),

              // TC (Temperatura Corporal)
              const SizedBox(height: 15),
              Center(child: const Text("Temperatura Corporal (TC)")),
              const SizedBox(height: 10),
              ...tcControllers.map((controller) {
                int index = tcControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "TC ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Por favor ingrese TC ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }).toList(),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addTcField,
                      child: Text("Agregar TC (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeTcField,
                      child: Text("Eliminar TC (-)"),
                    ),
                  ],
                ),
              ),

              // TAS (Tensión Arterial Sistólica)
              const SizedBox(height: 15),
              Center(child: const Text("Tensión Arterial Sistólica (TAS)")),
              const SizedBox(height: 10),
              ...tasControllers.map((controller) {
                int index = tasControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "TAS ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Por favor ingrese TAS ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }).toList(),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addTasField,
                      child: Text("Agregar TAS (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeTasField,
                      child: Text("Eliminar TAS (-)"),
                    ),
                  ],
                ),
              ),

              // TAD (Tensión Arterial Diastólica)
              const SizedBox(height: 15),
              Center(child: const Text("Tensión Arterial Diastólica (TAD)")),
              const SizedBox(height: 10),
              ...tadControllers.map((controller) {
                int index = tadControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "TAD ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Por favor ingrese TAD ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }).toList(),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addTadField,
                      child: Text("Agregar TAD (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeTadField,
                      child: Text("Eliminar TAD (-)"),
                    ),
                  ],
                ),
              ),

              // PVC (Presión Venosa Central)
              const SizedBox(height: 15),
              Center(child: const Text("Presión Venosa Central (PVC)")),
              const SizedBox(height: 10),
              ...pvcControllers.map((controller) {
                int index = pvcControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "PVC ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Por favor ingrese PVC ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }).toList(),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addPvcField,
                      child: Text("Agregar PVC (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removePvcField,
                      child: Text("Eliminar PVC (-)"),
                    ),
                  ],
                ),
              ),

              // FRECUENCIA RESPIRATORIA
              const SizedBox(height: 15),
              Center(child: const Text("Frecuencia Respiratoria")),
              const SizedBox(height: 10),
              ...frecRespiratoriaControllers.map((controller) {
                int index = frecRespiratoriaControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Frec. Respiratoria ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Por favor ingrese Frec. Respiratoria ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }).toList(),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addFrecRespiratoriaField,
                      child: Text("Agregar Frec. (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeFrecRespiratoriaField,
                      child: Text("Eliminar Frec. (-)"),
                    ),
                  ],
                ),
              ),

              // INFUSIÓN INTRAVENOSA
              const SizedBox(height: 30),
              Center(
                  child: const Text(
                "Infusión Intravenosa",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              )),
              const SizedBox(height: 15),

              // Fórmula
              const SizedBox(height: 15),
              Center(child: const Text("Fórmula")),
              const SizedBox(height: 10),
              ...formulaControllers.map((controller) {
                int index = formulaControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Fórmula ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if ((value?.length ?? 0) > 100) {
                        return 'Debe tener menos de 100 caracteres';
                      }
                      return null;
                    },
                  ),
                );
              }).toList(),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addFormulaField,
                      child: Text("Agregar Fórmula (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeFormulaField,
                      child: Text("Eliminar Fórmula (-)"),
                    ),
                  ],
                ),
              ),

              // DIETA
              const SizedBox(height: 30),
              Center(child: const Text("Dieta")),
              const SizedBox(height: 10),
              ...dietaControllers.map((controller) {
                int index = dietaControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Dieta ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if ((value?.length ?? 0) > 100) {
                        return 'Debe tener menos de 100 caracteres';
                      }
                      return null;
                    },
                  ),
                );
              }).toList(),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addDietaField,
                      child: Text("Agregar Dieta (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeDietaField,
                      child: Text("Eliminar Dieta (-)"),
                    ),
                  ],
                ),
              ),

              // LIQUIDOS ORALES
              const SizedBox(height: 30),
              Center(child: const Text("Liquidos Orales")),
              const SizedBox(height: 10),
              ...liqOralesControllers.map((controller) {
                int index = liqOralesControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Liquidos Orales ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if ((value?.length ?? 0) > 100) {
                        return 'Debe tener menos de 100 caracteres';
                      }
                      return null;
                    },
                  ),
                );
              }).toList(),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addLiqOralesField,
                      child: Text("Agregar Liquido (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeLiqOralesField,
                      child: Text("Eliminar Liquido (-)"),
                    ),
                  ],
                ),
              ),

              // MEDICAMENTOS
              const SizedBox(height: 30),
              Center(
                  child: const Text(
                "Medicamentos",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              )),
              const SizedBox(height: 15),

              // Medicamentos list
              ...addedMedicamentos.map((addedMed) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${addedMed.medicamento.nombre} - ${addedMed.cajas} cajas',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: openAddMedicamentoDialog,
                      child: Text("Agregar Medicamento (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeMedicamentoField,
                      child: Text("Eliminar Medicamento (-)"),
                    ),
                  ],
                ),
              ),

              // ESCALAS
              const SizedBox(height: 30),
              Center(
                  child: const Text(
                "Escalas",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              )),
              const SizedBox(height: 15),

              // Escala de Dolor EVA
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Dolor EVA",
                  border: OutlineInputBorder(),
                ),
                value: dolorEvaCon,
                items: escala
                    .map((option) => DropdownMenuItem(
                          child: Text(option),
                          value: option,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    dolorEvaCon = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione una opción';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Riesgo de Úlceras por Presión
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Riesgo de Úlceras por Presión",
                  border: OutlineInputBorder(),
                ),
                value: riesgoUlcerasPresCon,
                items: escala
                    .map((option) => DropdownMenuItem(
                          child: Text(option),
                          value: option,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    riesgoUlcerasPresCon = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione una opción';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Riesgo de Caídas
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Riesgo de Caídas",
                  border: OutlineInputBorder(),
                ),
                value: riesgoCaidasCon,
                items: escala
                    .map((option) => DropdownMenuItem(
                          child: Text(option),
                          value: option,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    riesgoCaidasCon = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione una opción';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Procesar datos
                    // Asignar timestamps aquí si es necesario
                  } else {
                    // Mostrar mensajes de error
                  }
                },
                child: Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
