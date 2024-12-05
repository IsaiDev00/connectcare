import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Model for Medicamento
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

// Model for Added Medication
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
  final TextEditingController totalIngresosController = TextEditingController();
  final TextEditingController totalEgresosController = TextEditingController();
  final TextEditingController totalBalanceController = TextEditingController();
  final TextEditingController dxMedicoController = TextEditingController();

  // MULTIPLE OPTIONS
  List<String> escala = ['A', 'M', 'B'];
  String? dolorEvaCon;
  String? riesgoUlcerasPresCon;
  String? riesgoCaidasCon;

  List<String> estadoOpciones = [
    'stable',
    'improving',
    'critical but stable',
    'serious',
    'emergency'
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
  List<TextEditingController> interColaboControllers = [];

  // UP TO 5 FIELDS
  // INTRAVENOUS INFUSION
  List<TextEditingController> ingOralControllers = [];
  List<TextEditingController> sondaControllers = [];
  List<TextEditingController> hemoControllers = [];
  List<TextEditingController> nutriParControllers = [];
  List<TextEditingController> solucionControllers = [];
  List<TextEditingController> otroControllers = [];
  List<TextEditingController> balanceControllers = [];
  List<TextEditingController> egresosUresisControllers = [];
  List<TextEditingController> evacuacionesControllers = [];
  List<TextEditingController> hemorragiaControllers = [];
  List<TextEditingController> vomAspControllers = [];
  List<TextEditingController> drenesControllers = [];
  List<TextEditingController> sinSigControllers = [];
  List<TextEditingController> pfControllers = [];
  List<TextEditingController> problemaInterControllers = [];
  List<TextEditingController> juicioClinicoControllers = [];
  List<TextEditingController> actEnfermeriaControllers = [];
  List<TextEditingController> respEvoControllers = [];
  List<TextEditingController> obsControllers = [];
  List<TextEditingController> planEgresoControllers = [];

  // MEDICATIONS
  List<AddedMedication> addedMedicamentos = [];

  // List of medications fetched from the database
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
    interColaboControllers.add(TextEditingController());

    ingOralControllers.add(TextEditingController());
    sondaControllers.add(TextEditingController());
    hemoControllers.add(TextEditingController());
    nutriParControllers.add(TextEditingController());
    solucionControllers.add(TextEditingController());
    otroControllers.add(TextEditingController());
    balanceControllers.add(TextEditingController());
    egresosUresisControllers.add(TextEditingController());
    evacuacionesControllers.add(TextEditingController());
    hemorragiaControllers.add(TextEditingController());
    vomAspControllers.add(TextEditingController());
    drenesControllers.add(TextEditingController());
    sinSigControllers.add(TextEditingController());
    pfControllers.add(TextEditingController());
    problemaInterControllers.add(TextEditingController());
    juicioClinicoControllers.add(TextEditingController());
    actEnfermeriaControllers.add(TextEditingController());
    respEvoControllers.add(TextEditingController());
    obsControllers.add(TextEditingController());
    planEgresoControllers.add(TextEditingController());

    _loadData();
  }

  // Funciones para obtener datos del backend
  Future<Map<String, dynamic>> obtenerDiagnostico(String nssPaciente) async {
    final response =
        await http.get(Uri.parse('$baseUrl/triage/diagnostico/$nssPaciente'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener diagnóstico: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> obtenerHojaEnfermeria(String nssPaciente) async {
    final response = await http
        .get(Uri.parse('$baseUrl/paciente/hoja_enfermeria/$nssPaciente'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener hoja de enfermería: ${response.body}');
    }
  }

  // Función para cargar datos al iniciar la pantalla
  void _loadData() async {
    try {
      String nssPaciente = '987654321';
      final diagnostico = await obtenerDiagnostico(nssPaciente);
      final hojaEnfermeria = await obtenerHojaEnfermeria(nssPaciente);

      setState(() {
        // Ahora, asignamos los valores a los controladores
        dxMedicoController.text = diagnostico['diagnostico'] ?? '';
        alergiasController.text = hojaEnfermeria['alergias'] ?? '';
        pesoController.text = hojaEnfermeria['peso'] != null
            ? hojaEnfermeria['peso'].toString()
            : '';
        estaturaController.text = hojaEnfermeria['estatura'] != null
            ? hojaEnfermeria['estatura'].toString()
            : '';
        estado = hojaEnfermeria['estado'] ?? '';
      });
    } catch (e) {
      // Manejar errores
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  // Functions to add fields
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

  void addInterColaboField() {
    if (interColaboControllers.length < 10) {
      setState(() {
        interColaboControllers.add(TextEditingController());
      });
    }
  }

  void addIngOralField() {
    if (ingOralControllers.length < 5) {
      setState(() {
        ingOralControllers.add(TextEditingController());
      });
    }
  }

  void addSondaField() {
    if (sondaControllers.length < 5) {
      setState(() {
        sondaControllers.add(TextEditingController());
      });
    }
  }

  void addHemoField() {
    if (hemoControllers.length < 5) {
      setState(() {
        hemoControllers.add(TextEditingController());
      });
    }
  }

  void addNutriParField() {
    if (nutriParControllers.length < 5) {
      setState(() {
        nutriParControllers.add(TextEditingController());
      });
    }
  }

  void addSolucionField() {
    if (solucionControllers.length < 5) {
      setState(() {
        solucionControllers.add(TextEditingController());
      });
    }
  }

  void addOtroField() {
    if (otroControllers.length < 5) {
      setState(() {
        otroControllers.add(TextEditingController());
      });
    }
  }

  void addBalanceField() {
    if (balanceControllers.length < 5) {
      setState(() {
        balanceControllers.add(TextEditingController());
      });
    }
  }

  void addEgresosUresisField() {
    if (egresosUresisControllers.length < 5) {
      setState(() {
        egresosUresisControllers.add(TextEditingController());
      });
    }
  }

  void addEvacuacionesField() {
    if (evacuacionesControllers.length < 5) {
      setState(() {
        evacuacionesControllers.add(TextEditingController());
      });
    }
  }

  void addHemorragiaField() {
    if (hemorragiaControllers.length < 5) {
      setState(() {
        hemorragiaControllers.add(TextEditingController());
      });
    }
  }

  void addVomAspField() {
    if (vomAspControllers.length < 5) {
      setState(() {
        vomAspControllers.add(TextEditingController());
      });
    }
  }

  void addDrenesField() {
    if (drenesControllers.length < 5) {
      setState(() {
        drenesControllers.add(TextEditingController());
      });
    }
  }

  void addSinSigField() {
    if (sinSigControllers.length < 5) {
      setState(() {
        sinSigControllers.add(TextEditingController());
      });
    }
  }

  void addPfField() {
    if (pfControllers.length < 5) {
      setState(() {
        pfControllers.add(TextEditingController());
      });
    }
  }

  void addProblemaInterField() {
    if (problemaInterControllers.length < 5) {
      setState(() {
        problemaInterControllers.add(TextEditingController());
      });
    }
  }

  void addJuicioClinicoField() {
    if (juicioClinicoControllers.length < 5) {
      setState(() {
        juicioClinicoControllers.add(TextEditingController());
      });
    }
  }

  void addActEnfermeriaField() {
    if (actEnfermeriaControllers.length < 5) {
      setState(() {
        actEnfermeriaControllers.add(TextEditingController());
      });
    }
  }

  void addRespEvoField() {
    if (respEvoControllers.length < 5) {
      setState(() {
        respEvoControllers.add(TextEditingController());
      });
    }
  }

  void addObsField() {
    if (obsControllers.length < 5) {
      setState(() {
        obsControllers.add(TextEditingController());
      });
    }
  }

  void addPlanEgresoField() {
    if (planEgresoControllers.length < 5) {
      setState(() {
        planEgresoControllers.add(TextEditingController());
      });
    }
  }

  // Functions to remove fields
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

  void removeInterColaboField() {
    if (interColaboControllers.length > 1) {
      setState(() {
        interColaboControllers.last.dispose();
        interColaboControllers.removeLast();
      });
    }
  }

  void removeIngOralField() {
    if (ingOralControllers.length > 1) {
      setState(() {
        ingOralControllers.last.dispose();
        ingOralControllers.removeLast();
      });
    }
  }

  void removeSondaField() {
    if (sondaControllers.length > 1) {
      setState(() {
        sondaControllers.last.dispose();
        sondaControllers.removeLast();
      });
    }
  }

  void removeHemoField() {
    if (hemoControllers.length > 1) {
      setState(() {
        hemoControllers.last.dispose();
        hemoControllers.removeLast();
      });
    }
  }

  void removeNutriParField() {
    if (nutriParControllers.length > 1) {
      setState(() {
        nutriParControllers.last.dispose();
        nutriParControllers.removeLast();
      });
    }
  }

  void removeSolucionField() {
    if (solucionControllers.length > 1) {
      setState(() {
        solucionControllers.last.dispose();
        solucionControllers.removeLast();
      });
    }
  }

  void removeOtroField() {
    if (otroControllers.length > 1) {
      setState(() {
        otroControllers.last.dispose();
        otroControllers.removeLast();
      });
    }
  }

  void removeBalanceField() {
    if (balanceControllers.length > 1) {
      setState(() {
        balanceControllers.last.dispose();
        balanceControllers.removeLast();
      });
    }
  }

  void removeEgresosUresisField() {
    if (egresosUresisControllers.length > 1) {
      setState(() {
        egresosUresisControllers.last.dispose();
        egresosUresisControllers.removeLast();
      });
    }
  }

  void removeEvacuacionesField() {
    if (evacuacionesControllers.length > 1) {
      setState(() {
        evacuacionesControllers.last.dispose();
        evacuacionesControllers.removeLast();
      });
    }
  }

  void removeHemorragiaField() {
    if (hemorragiaControllers.length > 1) {
      setState(() {
        hemorragiaControllers.last.dispose();
        hemorragiaControllers.removeLast();
      });
    }
  }

  void removeVomAspField() {
    if (vomAspControllers.length > 1) {
      setState(() {
        vomAspControllers.last.dispose();
        vomAspControllers.removeLast();
      });
    }
  }

  void removeDrenesField() {
    if (drenesControllers.length > 1) {
      setState(() {
        drenesControllers.last.dispose();
        drenesControllers.removeLast();
      });
    }
  }

  void removeSinSigField() {
    if (sinSigControllers.length > 1) {
      setState(() {
        sinSigControllers.last.dispose();
        sinSigControllers.removeLast();
      });
    }
  }

  void removePfField() {
    if (pfControllers.length > 1) {
      setState(() {
        pfControllers.last.dispose();
        pfControllers.removeLast();
      });
    }
  }

  void removeProblemaInterField() {
    if (problemaInterControllers.length > 1) {
      setState(() {
        problemaInterControllers.last.dispose();
        problemaInterControllers.removeLast();
      });
    }
  }

  void removeJuicioClinicoField() {
    if (juicioClinicoControllers.length > 1) {
      setState(() {
        juicioClinicoControllers.last.dispose();
        juicioClinicoControllers.removeLast();
      });
    }
  }

  void removeActEnfermeriaField() {
    if (actEnfermeriaControllers.length > 1) {
      setState(() {
        actEnfermeriaControllers.last.dispose();
        actEnfermeriaControllers.removeLast();
      });
    }
  }

  void removeRespEvoField() {
    if (respEvoControllers.length > 1) {
      setState(() {
        respEvoControllers.last.dispose();
        respEvoControllers.removeLast();
      });
    }
  }

  void removeObsField() {
    if (obsControllers.length > 1) {
      setState(() {
        obsControllers.last.dispose();
        obsControllers.removeLast();
      });
    }
  }

  void removePlanEgresoField() {
    if (planEgresoControllers.length > 1) {
      setState(() {
        planEgresoControllers.last.dispose();
        planEgresoControllers.removeLast();
      });
    }
  }

  void removeMedicamentoField() async {
    if (addedMedicamentos.isNotEmpty) {
      final AddedMedication? removed = await showDialog<AddedMedication>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Remove Medication'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: addedMedicamentos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(addedMedicamentos[index].medicamento.nombre),
                    subtitle: Text(
                        'Quantity: ${addedMedicamentos[index].cajas} boxes'),
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
                child: Text('Cancel'),
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

  // Function to open the medication selection dialog
  void openAddMedicamentoDialog() async {
    try {
      List<Medicamento> medicamentos = await fetchMedicamentos();
      setState(() {
        medicamentosList = medicamentos;
      });
    } catch (e) {
      // Handle API errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading medications')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        List<Medicamento> filteredMedicamentos = medicamentosList;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Select Medication'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search',
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
                SizedBox(
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
        // Show dialog to enter quantity of boxes
        String? errorMessage;
        int? cajas = await showDialog<int>(
          context: context,
          builder: (context) {
            TextEditingController cajasController = TextEditingController();
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: Text('Number of Boxes'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: cajasController,
                      decoration: InputDecoration(
                        labelText: 'Number of boxes',
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
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      int? value = int.tryParse(cajasController.text);
                      if (value == null || value <= 0) {
                        setState(() {
                          errorMessage = 'Enter a valid quantity';
                        });
                        return;
                      }
                      if (value > selectedMedicamento.cantidadStock) {
                        setState(() {
                          errorMessage =
                              'Cannot exceed available stock (${selectedMedicamento.cantidadStock})';
                        });
                        return;
                      }
                      Navigator.of(context).pop(value);
                    },
                    child: Text('Add'),
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

  // Function to fetch medications from the database
  Future<List<Medicamento>> fetchMedicamentos() async {
    final response = await http.get(Uri.parse('$baseUrl/medicamento/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Medicamento.fromJson(item)).toList();
    } else {
      throw Exception('Error loading medications');
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    alergiasController.dispose();
    pesoController.dispose();
    estaturaController.dispose();
    perimetroController.dispose();
    totalIngresosController.dispose();
    totalEgresosController.dispose();
    totalBalanceController.dispose();
    dxMedicoController.dispose();

    for (var controller in fcControllers) {
      controller.dispose();
    }
    for (var controller in tiControllers) {
      controller.dispose();
    }
    for (var controller in tcControllers) {
      controller.dispose();
    }
    for (var controller in tasControllers) {
      controller.dispose();
    }
    for (var controller in tadControllers) {
      controller.dispose();
    }
    for (var controller in pvcControllers) {
      controller.dispose();
    }
    for (var controller in frecRespiratoriaControllers) {
      controller.dispose();
    }
    for (var controller in interColaboControllers) {
      controller.dispose();
    }
    for (var controller in ingOralControllers) {
      controller.dispose();
    }
    for (var controller in sondaControllers) {
      controller.dispose();
    }
    for (var controller in hemoControllers) {
      controller.dispose();
    }
    for (var controller in nutriParControllers) {
      controller.dispose();
    }
    for (var controller in solucionControllers) {
      controller.dispose();
    }
    for (var controller in otroControllers) {
      controller.dispose();
    }
    for (var controller in balanceControllers) {
      controller.dispose();
    }
    for (var controller in egresosUresisControllers) {
      controller.dispose();
    }
    for (var controller in evacuacionesControllers) {
      controller.dispose();
    }
    for (var controller in hemorragiaControllers) {
      controller.dispose();
    }
    for (var controller in vomAspControllers) {
      controller.dispose();
    }
    for (var controller in drenesControllers) {
      controller.dispose();
    }
    for (var controller in sinSigControllers) {
      controller.dispose();
    }
    for (var controller in pfControllers) {
      controller.dispose();
    }
    for (var controller in problemaInterControllers) {
      controller.dispose();
    }
    for (var controller in juicioClinicoControllers) {
      controller.dispose();
    }
    for (var controller in actEnfermeriaControllers) {
      controller.dispose();
    }
    for (var controller in respEvoControllers) {
      controller.dispose();
    }
    for (var controller in obsControllers) {
      controller.dispose();
    }
    for (var controller in planEgresoControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      String fc = fcControllers.map((c) => c.text).join(', ');
      String ti = tiControllers.map((c) => c.text).join(', ');
      String tc = tcControllers.map((c) => c.text).join(', ');
      String tas = tasControllers.map((c) => c.text).join(', ');
      String tad = tadControllers.map((c) => c.text).join(', ');
      String pvc = pvcControllers.map((c) => c.text).join(', ');
      String frecResp =
          frecRespiratoriaControllers.map((c) => c.text).join(', ');
      String intervencionesColaboracion =
          interColaboControllers.map((c) => c.text).join(', ');

      String ingOral = ingOralControllers.map((c) => c.text).join(', ');
      String sonda = sondaControllers.map((c) => c.text).join(', ');
      String hemo = hemoControllers.map((c) => c.text).join(', ');
      String nutriPar = nutriParControllers.map((c) => c.text).join(', ');
      String solucion = solucionControllers.map((c) => c.text).join(', ');
      String otro = otroControllers.map((c) => c.text).join(', ');
      String balance = balanceControllers.map((c) => c.text).join(', ');
      String egresosUresis =
          egresosUresisControllers.map((c) => c.text).join(', ');
      String evacuaciones =
          evacuacionesControllers.map((c) => c.text).join(', ');
      String hemorragia = hemorragiaControllers.map((c) => c.text).join(', ');
      String vomAsp = vomAspControllers.map((c) => c.text).join(', ');
      String drenes = drenesControllers.map((c) => c.text).join(', ');
      String sinSig = sinSigControllers.map((c) => c.text).join(', ');
      String pf = pfControllers.map((c) => c.text).join(', ');
      String problemaInter =
          problemaInterControllers.map((c) => c.text).join(', ');
      String juicioClinico =
          juicioClinicoControllers.map((c) => c.text).join(', ');
      String actEnfermeria =
          actEnfermeriaControllers.map((c) => c.text).join(', ');
      String respEvo = respEvoControllers.map((c) => c.text).join(', ');
      String obs = obsControllers.map((c) => c.text).join(', ');
      String planEgreso = planEgresoControllers.map((c) => c.text).join(', ');

      Map<String, dynamic> data = {
        "fecha": DateTime.now().toIso8601String(),
        "codigo_temperatura": codigoTemp,
        "problema_interdependiente": problemaInter,
        "ta_sistolica": tas,
        "ta_diastolica": tad,
        "frecuencia_respiratoria": frecResp,
        "frecuencia_cardiaca": fc,
        "temperatura_interna": ti,
        "pvc": pvc,
        "perimetro": perimetroController.text,
        "pf": pf,
        "peso": pesoController.text,
        "intervenciones_colaboracion": intervencionesColaboracion,
        "dx_medico": dxMedicoController.text,
        "nss_paciente": 987654321,
        "alergias": alergiasController.text,
        "estatura": estaturaController.text,
        "total_ingresos": totalIngresosController.text,
        "total_egresos": totalEgresosController.text,
        "total_balance": totalBalanceController.text,
        "ing_oral": ingOral,
        "sonda": sonda,
        "hemo": hemo,
        "nutri_par": nutriPar,
        "solucion": solucion,
        "otro": otro,
        "balance": balance,
        "egresos_uresis": egresosUresis,
        "evacuaciones": evacuaciones,
        "hemorragia": hemorragia,
        "vom_asp": vomAsp,
        "drenes": drenes,
        "sin_sig": sinSig,
        "juicio_clinico": juicioClinico,
        "act_enfermeria": actEnfermeria,
        "resp_evo": respEvo,
        "obs": obs,
        "plan_egreso": planEgreso,
        "dolor_eva": dolorEvaCon,
        "riesgo_ulceras_pres": riesgoUlcerasPresCon,
        "riesgo_caidas": riesgoCaidasCon,
        "estado": estado,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/hoja_de_enfermeria/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully submitted')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting data')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fix the errors in the form')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nursing Sheet'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                  child: const Text(
                "General Information",
                style: TextStyle(
                  fontSize: 40.0,
                ),
              )),
              const SizedBox(height: 40),

              Text(
                "Actual Medical Diagnosis:",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 10),

              Text("(Change it if required)"),

              const SizedBox(height: 30),

              // Medical Diagnosis
              TextFormField(
                controller: dxMedicoController,
                decoration: InputDecoration(
                  labelText: 'Medical Diagnosis',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                maxLength: 100,
                validator: (value) {
                  if ((value?.isEmpty ?? true)) {
                    return 'Please enter the medical diagnosis';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              Text(
                "General Information:",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 30),

              // Allergies
              TextFormField(
                controller: alergiasController,
                decoration: InputDecoration(
                  labelText: 'Allergies',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                validator: (value) {
                  if ((value?.length ?? 0) > 100) {
                    return 'Must be less than 100 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Weight
              TextFormField(
                controller: pesoController,
                decoration: InputDecoration(
                  labelText: "Weight",
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the patient weight';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Height
              TextFormField(
                controller: estaturaController,
                decoration: InputDecoration(
                  labelText: "Height",
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the patient height';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Perimeter
              TextFormField(
                controller: perimetroController,
                decoration: InputDecoration(
                  labelText: "Perimeter (cm)",
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a perimeter in cm';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Patient State
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Patient State",
                  border: OutlineInputBorder(),
                ),
                value: estado,
                items: estadoOpciones
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(option,
                              style: TextStyle(
                                fontSize: 15,
                              )),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    estado = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please choose an option';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Temperature Code
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Temperature Code",
                  border: OutlineInputBorder(),
                ),
                value: codigoTemp,
                items: codigoTempOpciones
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(
                            option,
                            style: TextStyle(fontSize: 15),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    codigoTemp = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please choose a code';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // VITAL SIGNS
              Center(
                  child: const Text(
                "Vital Signs",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              )),
              const SizedBox(height: 15),

              // FC (Heart Rate)
              Center(child: const Text("Heart Rate (FC)")),
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
                        return 'Please enter FC ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addFcField,
                      child: Text("Add FC (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeFcField,
                      child: Text("Remove FC (-)"),
                    ),
                  ],
                ),
              ),

              // TI (Internal Temperature)
              const SizedBox(height: 15),
              Center(child: const Text("Internal Temperature (TI)")),
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
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Please enter TI ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addTiField,
                      child: Text("Add TI (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeTiField,
                      child: Text("Remove TI (-)"),
                    ),
                  ],
                ),
              ),

              // TC (Body Temperature)
              const SizedBox(height: 15),
              Center(child: const Text("Body Temperature (TC)")),
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
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Please enter TC ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addTcField,
                      child: Text("Add TC (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeTcField,
                      child: Text("Remove TC (-)"),
                    ),
                  ],
                ),
              ),

              // TAS (Systolic Blood Pressure)
              const SizedBox(height: 15),
              Center(child: const Text("Systolic Blood Pressure (TAS)")),
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
                        return 'Please enter TAS ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addTasField,
                      child: Text("Add TAS (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeTasField,
                      child: Text("Remove TAS (-)"),
                    ),
                  ],
                ),
              ),

              // TAD (Diastolic Blood Pressure)
              const SizedBox(height: 15),
              Center(child: const Text("Diastolic Blood Pressure (TAD)")),
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
                        return 'Please enter TAD ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addTadField,
                      child: Text("Add TAD (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeTadField,
                      child: Text("Remove TAD (-)"),
                    ),
                  ],
                ),
              ),

              // PVC (Central Venous Pressure)
              const SizedBox(height: 15),
              Center(child: const Text("Central Venous Pressure (PVC)")),
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
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Please enter PVC ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addPvcField,
                      child: Text("Add PVC (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removePvcField,
                      child: Text("Remove PVC (-)"),
                    ),
                  ],
                ),
              ),

              // Respiratory Rate
              const SizedBox(height: 15),
              Center(child: const Text("Respiratory Rate")),
              const SizedBox(height: 10),
              ...frecRespiratoriaControllers.map((controller) {
                int index = frecRespiratoriaControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Respiratory Rate ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Please enter Respiratory Rate ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addFrecRespiratoriaField,
                      child: Text("Add Rate (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeFrecRespiratoriaField,
                      child: Text("Remove Rate (-)"),
                    ),
                  ],
                ),
              ),

              // Interventions in Collaboration
              const SizedBox(height: 15),
              Center(child: const Text("Interventions in Collaboration")),
              const SizedBox(height: 10),
              ...interColaboControllers.map((controller) {
                int index = interColaboControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Intervention ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 200,
                    validator: (value) {
                      if ((value?.length ?? 0) > 200) {
                        return 'Must be less than 200 characters';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addInterColaboField,
                      child: Text("Add Intervention (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeInterColaboField,
                      child: Text("Remove Intervention (-)"),
                    ),
                  ],
                ),
              ),

              // CONTROL OF LIQUIDS
              const SizedBox(height: 30),
              Center(
                  child: const Text(
                "Control of Liquids",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              )),
              const SizedBox(height: 15),

              // Oral Intake
              const SizedBox(height: 15),
              Center(child: const Text("Oral Intake")),
              const SizedBox(height: 10),
              ...ingOralControllers.map((controller) {
                int index = ingOralControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Oral Intake ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if ((value?.length ?? 0) > 100) {
                        return 'Must be less than 100 characters';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addIngOralField,
                      child: Text("Add Intake (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeIngOralField,
                      child: Text("Remove Intake (-)"),
                    ),
                  ],
                ),
              ),

              // Sonda
              const SizedBox(height: 15),
              Center(child: const Text("Sonda")),
              const SizedBox(height: 10),
              ...sondaControllers.map((controller) {
                int index = sondaControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Sonda ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if ((value?.length ?? 0) > 100) {
                        return 'Must be less than 100 characters';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addSondaField,
                      child: Text("Add Sonda (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeSondaField,
                      child: Text("Remove Sonda (-)"),
                    ),
                  ],
                ),
              ),

              // Hemoderivatives
              const SizedBox(height: 15),
              Center(child: const Text("Hemoderivatives")),
              const SizedBox(height: 10),
              ...hemoControllers.map((controller) {
                int index = hemoControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Hemoderivative ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if ((value?.length ?? 0) > 100) {
                        return 'Must be less than 100 characters';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addHemoField,
                      child: Text("Add Hemoderivative (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeHemoField,
                      child: Text("Remove Hemoderivative (-)"),
                    ),
                  ],
                ),
              ),

              // Nutri Parenteral Total
              const SizedBox(height: 15),
              Center(child: const Text("Total Parenteral Nutrition")),
              const SizedBox(height: 10),
              ...nutriParControllers.map((controller) {
                int index = nutriParControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Parenteral Nutrition ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if ((value?.length ?? 0) > 100) {
                        return 'Must be less than 100 characters';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addNutriParField,
                      child: Text("Add Nutrition (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeNutriParField,
                      child: Text("Remove Nutrition (-)"),
                    ),
                  ],
                ),
              ),

              // IV Solutions
              const SizedBox(height: 15),
              Center(child: const Text("IV Solutions")),
              const SizedBox(height: 10),
              ...solucionControllers.map((controller) {
                int index = solucionControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Solution ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if ((value?.length ?? 0) > 100) {
                        return 'Must be less than 100 characters';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addSolucionField,
                      child: Text("Add Solution (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeSolucionField,
                      child: Text("Remove Solution (-)"),
                    ),
                  ],
                ),
              ),

              // Other
              const SizedBox(height: 15),
              Center(child: const Text("Other")),
              const SizedBox(height: 10),
              ...otroControllers.map((controller) {
                int index = otroControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Field ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if ((value?.length ?? 0) > 100) {
                        return 'Must be less than 100 characters';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addOtroField,
                      child: Text("Add Field (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeOtroField,
                      child: Text("Remove Field (-)"),
                    ),
                  ],
                ),
              ),

              // Balance 24 hrs
              const SizedBox(height: 15),
              Center(child: const Text("24-Hour Balance")),
              const SizedBox(height: 10),
              ...balanceControllers.map((controller) {
                int index = balanceControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Balance ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if ((value?.length ?? 0) > 100) {
                        return 'Must be less than 100 characters';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addBalanceField,
                      child: Text("Add Balance (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeBalanceField,
                      child: Text("Remove Balance (-)"),
                    ),
                  ],
                ),
              ),

              // Egress via Uresis
              const SizedBox(height: 15),
              Center(child: const Text("Egress via Uresis")),
              const SizedBox(height: 10),
              ...egresosUresisControllers.map((controller) {
                int index = egresosUresisControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Egress ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if ((value?.length ?? 0) > 100) {
                        return 'Must be less than 100 characters';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addEgresosUresisField,
                      child: Text("Add Egress (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeEgresosUresisField,
                      child: Text("Remove Egress (-)"),
                    ),
                  ],
                ),
              ),

              // Evacuations
              const SizedBox(height: 15),
              Center(child: const Text("Evacuations")),
              const SizedBox(height: 10),
              ...evacuacionesControllers.map((controller) {
                int index = evacuacionesControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Evacuation ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if ((value?.length ?? 0) > 100) {
                        return 'Must be less than 100 characters';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addEvacuacionesField,
                      child: Text("Add Evacuation (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeEvacuacionesField,
                      child: Text("Remove Evacuation (-)"),
                    ),
                  ],
                ),
              ),

              // Hemorrhages
              const SizedBox(height: 15),
              Center(child: const Text("Hemorrhages")),
              const SizedBox(height: 10),
              ...hemorragiaControllers.map((controller) {
                int index = hemorragiaControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Hemorrhage ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if ((value?.length ?? 0) > 100) {
                        return 'Must be less than 100 characters';
                      }
                      return null;
                    },
                  ),
                );
              }),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addHemorragiaField,
                      child: Text("Add Hemorrhage (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeHemorragiaField,
                      child: Text("Remove Hemorrhage (-)"),
                    ),
                  ],
                ),
              ),

              // Vomits/Aspiration
              const SizedBox(height: 15),
              Center(child: const Text("Vomits/Aspiration")),
              const SizedBox(height: 10),
              ...vomAspControllers.map((controller) {
                int index = vomAspControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Vomit/Aspiration ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if ((value?.length ?? 0) > 100) {
                        return 'Must be less than 100 characters';
                      }
                      return null;
                    },
                  ),
                );
              }),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addVomAspField,
                      child: Text("Add Field (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeVomAspField,
                      child: Text("Remove Field (-)"),
                    ),
                  ],
                ),
              ),

              // Drains
              const SizedBox(height: 15),
              Center(child: const Text("Drains")),
              const SizedBox(height: 10),
              ...drenesControllers.map((controller) {
                int index = drenesControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Drain ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if ((value?.length ?? 0) > 100) {
                        return 'Must be less than 100 characters';
                      }
                      return null;
                    },
                  ),
                );
              }),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addDrenesField,
                      child: Text("Add Drain (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeDrenesField,
                      child: Text("Remove Drain (-)"),
                    ),
                  ],
                ),
              ),

              // TOTAL INCOME
              const SizedBox(height: 15),
              TextFormField(
                controller: totalIngresosController,
                decoration: const InputDecoration(
                  labelText: "Total Income",
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the total income';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // TOTAL EXPENSES
              TextFormField(
                controller: totalEgresosController,
                decoration: InputDecoration(
                  labelText: "Total Expenses",
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the total expenses';
                  }
                  return null;
                },
              ),

              SizedBox(height: 15),

              // TOTAL BALANCE
              TextFormField(
                controller: totalBalanceController,
                decoration: InputDecoration(
                  labelText: "Total Liquid Balance",
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the total liquid balance';
                  }
                  return null;
                },
              ),

              // MEDICATIONS
              const SizedBox(height: 30),
              Center(
                  child: const Text(
                "Medications",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              )),
              const SizedBox(height: 15),

              // Medications list
              ...addedMedicamentos.map((addedMed) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${addedMed.medicamento.nombre} - ${addedMed.cajas} boxes',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: openAddMedicamentoDialog,
                      child: Text("Add Medication (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeMedicamentoField,
                      child: Text("Remove Medication (-)"),
                    ),
                  ],
                ),
              ),

              // SCALES
              const SizedBox(height: 30),
              Center(
                  child: const Text(
                "Scales",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              )),
              const SizedBox(height: 15),

              // Pain Scale EVA
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Pain EVA",
                  border: OutlineInputBorder(),
                ),
                value: dolorEvaCon,
                items: escala
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(
                            option,
                            style: TextStyle(fontSize: 15),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    dolorEvaCon = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an option';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Risk of Pressure Ulcers
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Risk of Pressure Ulcers",
                  border: OutlineInputBorder(),
                ),
                value: riesgoUlcerasPresCon,
                items: escala
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(
                            option,
                            style: TextStyle(fontSize: 15),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    riesgoUlcerasPresCon = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an option';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Risk of Falls
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Risk of Falls",
                  border: OutlineInputBorder(),
                ),
                value: riesgoCaidasCon,
                items: escala
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(
                            option,
                            style: TextStyle(fontSize: 15),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    riesgoCaidasCon = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an option';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              //PF
              Center(child: const Text("Functional Plan (PF)")),
              const SizedBox(height: 10),
              ...pfControllers.map((controller) {
                int index = pfControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "PF ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Please enter PF ${index + 1}';
                      } else if (int.parse(value!) > 11 ||
                          int.parse(value) < 1) {
                        return 'PF ${index + 1} must be between 1 and 11';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addPfField,
                      child: Text("Add PF (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removePfField,
                      child: Text("Remove PF (-)"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              //SINTOMAS Y SIGNOS
              Center(child: const Text("Symptoms and Signs")),
              const SizedBox(height: 10),
              ...sinSigControllers.map((controller) {
                int index = sinSigControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Symptom or sign ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Please enter the symptom or sign No. ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addSinSigField,
                      child: Text("Add S&S (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeSinSigField,
                      child: Text("Remove S&S (-)"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              //PROBLEMA INTERDEPENDIENTE
              Center(child: const Text("Interdependent problem")),
              const SizedBox(height: 10),
              ...problemaInterControllers.map((controller) {
                int index = problemaInterControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Interdependent problem ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Please enter the interdependent problem No. ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addProblemaInterField,
                      child: Text("Add I.P. (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeProblemaInterField,
                      child: Text("Remove I.P. (-)"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              //JUICIO CLINICO
              Center(child: const Text("Clinical trial")),
              const SizedBox(height: 10),
              ...juicioClinicoControllers.map((controller) {
                int index = juicioClinicoControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Clinical trial ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Please enter the clinical trial No. ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addJuicioClinicoField,
                      child: Text("Add clinical trial (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeJuicioClinicoField,
                      child: Text("Remove clinical trial (-)"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              //ACTIVIDADES DE ENFERMERIA
              Center(child: const Text("Nursing activities")),
              const SizedBox(height: 10),
              ...actEnfermeriaControllers.map((controller) {
                int index = actEnfermeriaControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Nursing activities ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Please enter the nurse activity No. ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addActEnfermeriaField,
                      child: Text("Add a nurse activity (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeActEnfermeriaField,
                      child: Text("Remove a nurse activity (-)"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              //RESPUESTA Y EVOLUCION
              Center(child: const Text("Response and evolution")),
              const SizedBox(height: 10),
              ...respEvoControllers.map((controller) {
                int index = respEvoControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Response and Evo No. ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Please enter the response and evo No. ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addRespEvoField,
                      child: Text("Add response and evo (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeRespEvoField,
                      child: Text("Remove response and evo (-)"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              //OBSERVACIONES
              Center(child: const Text("Observations")),
              const SizedBox(height: 10),
              ...obsControllers.map((controller) {
                int index = obsControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Observation No. ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Please enter the observation No. ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addObsField,
                      child: Text("Add observation (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeObsField,
                      child: Text("Remove observation (-)"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              //PLAN DE EGRESO
              Center(child: const Text("Egress plan")),
              const SizedBox(height: 10),
              ...planEgresoControllers.map((controller) {
                int index = planEgresoControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Egress plan No. ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if ((value?.isEmpty ?? true)) {
                        return 'Please enter the egress plan No. ${index + 1}';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addPlanEgresoField,
                      child: Text("Add egress plan (+)"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removePlanEgresoField,
                      child: Text("Remove egress plan (-)"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
