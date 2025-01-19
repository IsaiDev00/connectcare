import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:easy_localization/easy_localization.dart';
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
      // Si 'id_administrador' no existe o es null, usamos 0 por defecto.
      idAdministrador: json['id_administrador'] ?? 0,
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
  final String nssPaciente;
  const HojaEnfermeriaScreen({super.key, required this.nssPaciente});

  @override
  _HojaEnfermeriaScreen createState() => _HojaEnfermeriaScreen();
}

class _HojaEnfermeriaScreen extends State<HojaEnfermeriaScreen> {
  final _formKey = GlobalKey<FormState>();

  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  String? idMedico;
  String idPersonal = '';
  String nss = '';
  // PATIENT INFORMATION
  String? nombrePaciente;
  double? edad;
  int? diasInterno;
  String? servicio;
  String? sala;
  int? camaNum;
  String? fechaIngreso;
  String? sexo;
  String? gpo_rh;
  String? fechaNacimiento;
  String? fechaHoy;
  List<String>? idEnfermeros;
  List<String>? nombreEnfermeros;

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

  // VITAL SIGNS
  List<TextEditingController> fcControllers = [];
  List<TextEditingController> tiControllers = [];
  List<TextEditingController> tcControllers = [];
  List<TextEditingController> tasControllers = [];
  List<TextEditingController> tadControllers = [];
  List<TextEditingController> pvcControllers = [];
  List<TextEditingController> frecRespiratoriaControllers = [];
  List<TextEditingController> interColaboControllers = [];

  // CONTROL OF LIQUIDS
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

  // NUEVA SECCION: INFUSIÓN INTRAVENOSA
  // 3 datos (formula, dieta, líquidos orales) con hasta 5 campos cada uno, y 1 total (un solo campo).
  List<TextEditingController> formulaControllers = [];
  List<TextEditingController> dietaControllers = [];
  List<TextEditingController> liquidosOralesInfControllers = [];
  final TextEditingController totalInfusionController = TextEditingController();

  // MEDICATIONS
  List<AddedMedication> addedMedicamentos = [];

  // List of medications fetched from the database
  List<Medicamento> medicamentosList = [];

  @override
  void initState() {
    super.initState();
    _getID();
    nss = widget.nssPaciente;
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

    // Inicializamos la sección de Infusión intravenosa
    formulaControllers.add(TextEditingController());
    dietaControllers.add(TextEditingController());
    liquidosOralesInfControllers.add(TextEditingController());

    _loadData();
  }

  Future<void> _getID() async {
    final data = await _sharedPreferencesService.getUserId();
    if (data != null) {
      setState(() {
        idPersonal = data;
      });
    }
    try {
      final url = Uri.parse('$baseUrl/medico/id/$idPersonal');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            idMedico = data[0]['id_medico'].toString();
          });
        }
      } else if (response.statusCode == 404) {
        debugPrint('El médico con idPersonal: $idPersonal no existe');
      } else {
        debugPrint('Error inesperado. Código: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Ha ocurrido un error al obtener el idMedico: $e');
    }
  }

  Future<Map<String, dynamic>> obtenerDiagnostico(String nssPaciente) async {
    final response =
        await http.get(Uri.parse('$baseUrl/triage/diagnostico/$nssPaciente'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener diagnóstico: ${response.body}');
    }
  }

  Future<bool> removeMedicationWithConfirmation(
    BuildContext context,
    AddedMedication medicationToRemove,
  ) async {
    final bool? shouldRemove = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Eliminar medicamento'),
          content: Text(
            '¿Estás seguro de que deseas eliminar "${medicationToRemove.medicamento.nombre}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );

    // Si el usuario presionó "Eliminar" (true), removemos el medicamento
    if (shouldRemove == true) {
      setState(() {
        addedMedicamentos.remove(medicationToRemove);
      });
      return true; // Se eliminó exitosamente
    }

    return false; // No se eliminó
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

  void _loadData() async {
    try {
      final diagnostico = await obtenerDiagnostico(nss);
      final hojaEnfermeria = await obtenerHojaEnfermeria(nss);

      setState(() {
        final hoy = DateTime.now();
        // Formato amigable de la fecha de hoy (opcional).
        fechaHoy = DateFormat('yyyy-MM-dd').format(hoy);

        // Desglosamos la respuesta
        final pacienteData = hojaEnfermeria['paciente'] ?? {};
        final camaData = hojaEnfermeria['cama'] ?? {};
        final salaData = hojaEnfermeria['sala'] ?? {};
        final servicioData = hojaEnfermeria['servicio'] ?? {};
        final enfermerosRaw = hojaEnfermeria['enfermeros'] ?? [];

        // Nombre completo
        nombrePaciente = ((pacienteData['nombre'] ?? '') +
                ' ' +
                (pacienteData['apellido_paterno'] ?? '') +
                ' ' +
                (pacienteData['apellido_materno'] ?? ''))
            .trim();

        // Fecha de nacimiento y edad
        if (pacienteData['fecha_nacimiento'] != null) {
          final fechaNacDT = DateTime.parse(pacienteData['fecha_nacimiento']);
          // Guardamos con formato yyyy-MM-dd
          fechaNacimiento = DateFormat('yyyy-MM-dd').format(fechaNacDT);

          int years = hoy.year - fechaNacDT.year;
          if (hoy.month < fechaNacDT.month ||
              (hoy.month == fechaNacDT.month && hoy.day < fechaNacDT.day)) {
            years--;
          }
          edad = years.toDouble();
        }

        // Fecha de ingreso y días interno
        if (pacienteData['fecha_entrada'] != null) {
          final fechaIngDT = DateTime.parse(pacienteData['fecha_entrada']);
          fechaIngreso = DateFormat('yyyy-MM-dd').format(fechaIngDT);
          diasInterno = hoy.difference(fechaIngDT).inDays;
        }

        // Sala (concatenamos nombre + número)
        sala = '${salaData['nombre'] ?? ''} ${salaData['numero'] ?? ''}'.trim();

        // Servicio
        servicio = servicioData['nombre'] ?? '';

        // Cama: si viene como int, lo asignamos; si no, null
        camaNum =
            (camaData['numero_cama'] is int) ? camaData['numero_cama'] : null;

        // Sexo, grupo y rh
        sexo = pacienteData['sexo']?.toString() ?? '';
        gpo_rh = pacienteData['gpo_y_rh']?.toString() ?? '';

        // ENFERMEROS
        final List<Map<String, dynamic>> enfermerosList =
            List<Map<String, dynamic>>.from(enfermerosRaw);
        idEnfermeros = enfermerosList
            .map((e) => e['id_enfermero']?.toString() ?? '')
            .toList();
        nombreEnfermeros = enfermerosList
            .map((e) => e['nombre_completo']?.toString() ?? '')
            .toList();

        // Lógica Original
        dxMedicoController.text = diagnostico['diagnostico'] ?? '';
        alergiasController.text = pacienteData['alergias']?.toString() ?? '';

        // Si en la BD estos campos son DECIMAL, el backend los envía como string ("76.00", "1.81").
        // Simplemente los mostramos como string en los TextFields.
        pesoController.text = pacienteData['peso']?.toString() ?? '';
        estaturaController.text = pacienteData['estatura']?.toString() ?? '';

        // Estado (string)
        estado = pacienteData['estado']?.toString() ?? '';
      });
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

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

  // NUEVAS FUNCIONES PARA INFUSIÓN INTRAVENOSA
  void addFormulaField() {
    if (formulaControllers.length < 5) {
      setState(() {
        formulaControllers.add(TextEditingController());
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

  void addDietaField() {
    if (dietaControllers.length < 5) {
      setState(() {
        dietaControllers.add(TextEditingController());
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

  void addLiquidosInfField() {
    if (liquidosOralesInfControllers.length < 5) {
      setState(() {
        liquidosOralesInfControllers.add(TextEditingController());
      });
    }
  }

  void removeLiquidosInfField() {
    if (liquidosOralesInfControllers.length > 1) {
      setState(() {
        liquidosOralesInfControllers.last.dispose();
        liquidosOralesInfControllers.removeLast();
      });
    }
  }

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
      await showDialog<AddedMedication>(
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
                    onTap: () async {
                      // 1) Llamas a la confirmación
                      bool removed = await removeMedicationWithConfirmation(
                        context,
                        addedMedicamentos[index],
                      );
                      // 2) Si realmente se eliminó, cierras la alerta de la lista
                      if (removed) {
                        Navigator.of(context).pop();
                      }
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

      // Llamar a setState fuera del diálogo, por si acaso:
      setState(() {});
    }
  }

  void openAddMedicamentoDialog() async {
    try {
      List<Medicamento> medicamentos = await fetchMedicamentos();
      setState(() {
        medicamentosList = medicamentos;
      });
    } catch (e) {
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
            if (addedMedicamentos.length < 20) {
              addedMedicamentos.add(AddedMedication(
                  medicamento: selectedMedicamento, cajas: cajas));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cant add more than 20 medications')),
              );
            }
          });
        }
      }
    });
  }

  Future<List<Medicamento>> fetchMedicamentos() async {
    final clues = await _sharedPreferencesService.getClues();
    final response =
        await http.get(Uri.parse('$baseUrl/medicamento/?clues=$clues'));

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Medicamento.fromJson(item)).toList();
    } else {
      throw Exception('Error loading medications: ${response.body}');
    }
  }

  @override
  void dispose() {
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

    for (var controller in formulaControllers) {
      controller.dispose();
    }
    for (var controller in dietaControllers) {
      controller.dispose();
    }
    for (var controller in liquidosOralesInfControllers) {
      controller.dispose();
    }
    totalInfusionController.dispose();

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

      // NUEVOS CAMPOS PARA INFUSIÓN INTRAVENOSA
      String formula = formulaControllers.map((c) => c.text).join(', ');
      String dieta = dietaControllers.map((c) => c.text).join(', ');
      String liquidosInf =
          liquidosOralesInfControllers.map((c) => c.text).join(', ');
      String totalInfusion = totalInfusionController.text;

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
        "nss_paciente": nss,
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
        "id_medico": idMedico,
        "tc": tc,
        // CAMPOS NUEVOS DE INFUSIÓN INTRAVENOSA
        "formula_inf": formula,
        "dieta_inf": dieta,
        "liquidos_inf": liquidosInf,
        "total_inf": totalInfusion,
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
        SnackBar(content: Text('Please fill the missing fields in the form')),
      );
    }
  }

  Future<void> sendReport(String message) async {
    final urlGet = "$baseUrl/paciente_familiar/familiar/$nss";
    final responseGet = await http.get(Uri.parse(urlGet));

    if (responseGet.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Este paciente no tiene familiares vinculados")));
      return;
    }

    final jsonGet = jsonDecode(responseGet.body);
    if (jsonGet["id_familiar"] == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Este paciente no tiene familiares vinculados")));
      return;
    }

    final familyId = jsonGet["id_familiar"];
    final urlPost = "$baseUrl/firebase_notification/send-notification";
    final title = "Your relative need their medicine";
    final body = message.isEmpty
        ? "You have not brought some necesary medications"
        : message;

    final responsePost = await http.post(
      Uri.parse(urlPost),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": familyId, "title": title, "body": body}),
    );

    // Opcional: manejar la respuesta del envío de la notificación
    if (responsePost.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("The family member has been notificated")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error notificating the family member")));
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "General Information",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Text("Name:  $nombrePaciente"),
              const SizedBox(height: 10),
              Text("Age: $edad"),
              const SizedBox(height: 10),
              Text("Current days interned: $diasInterno"),
              const SizedBox(height: 10),
              Text("Service: $servicio"),
              const SizedBox(height: 10),
              Text("Room: $sala"),
              const SizedBox(height: 10),
              Text("Bed number $camaNum"),
              const SizedBox(height: 10),
              Text("NSS: $nss"),
              const SizedBox(height: 10),
              Text("Entry date: $fechaIngreso"),
              const SizedBox(height: 10),
              Text("Sex: $sexo"),
              const SizedBox(height: 10),
              Text("Gpo and RH: $gpo_rh"),
              const SizedBox(height: 10),
              Text("Date of birth: $fechaNacimiento"),
              const SizedBox(height: 10),
              Text("Today's date: $fechaHoy"),
              const SizedBox(height: 20),

              Text("Actual nurse/s:"),

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: idEnfermeros?.length ?? 0,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      subtitle: Text('Name: ${nombreEnfermeros![index]}'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

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
                autofocus: false,
                maxLength: 100,
                validator: (value) {
                  if ((value?.isEmpty ?? true)) {
                    return 'Please enter the medical diagnosis';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

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
                      child: Text("Add FC (+)", style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeFcField,
                      child:
                          Text("Remove FC (-)", style: TextStyle(fontSize: 10)),
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
                      child: Text("Add TI (+)", style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeTiField,
                      child:
                          Text("Remove TI (-)", style: TextStyle(fontSize: 10)),
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
                      child: Text("Add TC (+)", style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeTcField,
                      child:
                          Text("Remove TC (-)", style: TextStyle(fontSize: 10)),
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
                      child:
                          Text("Add TAS (+)", style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeTasField,
                      child: Text("Remove TAS (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child:
                          Text("Add TAD (+)", style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeTadField,
                      child: Text("Remove TAD (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child:
                          Text("Add PVC (+)", style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removePvcField,
                      child: Text("Remove PVC (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child:
                          Text("Add Rate (+)", style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeFrecRespiratoriaField,
                      child: Text("Remove Rate (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child: Text("Add Intervention (+)",
                          style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeInterColaboField,
                      child: Text("Remove Intervention (-)",
                          style: TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ),

              // NUEVA SECCIÓN: INFUSIÓN INTRAVENOSA
              const SizedBox(height: 30),
              Center(
                  child: const Text(
                "Intravenous Infusion",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              )),
              const SizedBox(height: 15),

              // Formula
              const SizedBox(height: 15),
              Center(child: const Text("Formula")),
              const SizedBox(height: 10),
              ...formulaControllers.map((controller) {
                int index = formulaControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Formula ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
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
                      onPressed: addFormulaField,
                      child: Text("Add Formula (+)",
                          style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeFormulaField,
                      child: Text("Remove Formula (-)",
                          style: TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ),

              // Dieta
              const SizedBox(height: 15),
              Center(child: const Text("Diet")),
              const SizedBox(height: 10),
              ...dietaControllers.map((controller) {
                int index = dietaControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Diet ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
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
                      onPressed: addDietaField,
                      child:
                          Text("Add Diet (+)", style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeDietaField,
                      child: Text("Remove Diet (-)",
                          style: TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ),

              // Líquidos orales
              const SizedBox(height: 15),
              Center(child: const Text("Oral Liquids")),
              const SizedBox(height: 10),
              ...liquidosOralesInfControllers.map((controller) {
                int index = liquidosOralesInfControllers.indexOf(controller);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Oral Liquids ${index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
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
                      onPressed: addLiquidosInfField,
                      child: Text("Add Liquids (+)",
                          style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeLiquidosInfField,
                      child: Text("Remove Liquids (-)",
                          style: TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ),

              // Total (un solo campo)
              const SizedBox(height: 15),
              Center(child: const Text("Total Infusion")),
              const SizedBox(height: 10),
              TextFormField(
                controller: totalInfusionController,
                decoration: InputDecoration(
                  labelText: "Total Infusion",
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                validator: (value) {
                  return null;
                },
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
                      child: Text("Add Intake (+)",
                          style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeIngOralField,
                      child: Text("Remove Intake (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child:
                          Text("Add Sonda (+)", style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeSondaField,
                      child: Text("Remove Sonda (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child: Text("Add \nHemoderivative (+)",
                          style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeHemoField,
                      child: Text("Remove \nHemoderivative (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child: Text("Add Nutrition (+)",
                          style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeNutriParField,
                      child: Text("Remove Nutrition (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child: Text("Add Solution (+)",
                          style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeSolucionField,
                      child: Text("Remove Solution (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child:
                          Text("Add Field (+)", style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeOtroField,
                      child: Text("Remove Field (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child: Text("Add Balance (+)",
                          style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeBalanceField,
                      child: Text("Remove Balance (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child: Text("Add Egress (+)",
                          style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeEgresosUresisField,
                      child: Text("Remove Egress (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child: Text("Add Evacuation (+)",
                          style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeEvacuacionesField,
                      child: Text("Remove Evacuation (-)",
                          style: TextStyle(fontSize: 10)),
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
                      if ((value?.isEmpty ?? true)) {
                        return 'Please enter the hemorrhage No. ${index + 1}';
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
                      child: Text("Add Hemorrhage (+)",
                          style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeHemorragiaField,
                      child: Text("Remove Hemorrhage (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child:
                          Text("Add Field (+)", style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeVomAspField,
                      child: Text("Remove Field (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child:
                          Text("Add Drain (+)", style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeDrenesField,
                      child: Text("Remove Drain (-)",
                          style: TextStyle(fontSize: 10)),
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
                autofocus: false,
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
                autofocus: false,
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
                autofocus: false,
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
                      child: Text("Add Medication (+)",
                          style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeMedicamentoField,
                      child: Text("Remove Medication (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child: Text("Add PF (+)", style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removePfField,
                      child:
                          Text("Remove PF (-)", style: TextStyle(fontSize: 10)),
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
                      child:
                          Text("Add S&S (+)", style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeSinSigField,
                      child: Text("Remove S&S (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child:
                          Text("Add I.P. (+)", style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeProblemaInterField,
                      child: Text("Remove I.P. (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child: Text("Add clinical trial (+)",
                          style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeJuicioClinicoField,
                      child: Text("Remove clinical trial (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child: Text("Add a nurse \nactivity (+)",
                          style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeActEnfermeriaField,
                      child: Text("Remove a nurse \nactivity (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child: Text("Add response \nand evo (+)",
                          style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeRespEvoField,
                      child: Text("Remove response \nand evo (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child: Text("Add observation (+)",
                          style: TextStyle(fontSize: 10)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeObsField,
                      child: Text("Remove observation (-)",
                          style: TextStyle(fontSize: 10)),
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
                      child: Text(
                        "Add egress plan (+)",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removePlanEgresoField,
                      child: Text(
                        "Remove egress plan (-)",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Color de fondo rojo
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        String message = "";
                        return AlertDialog(
                          title: Text("Report lack of requested medications"),
                          content: TextField(
                            onChanged: (value) {
                              message = value;
                            },
                            decoration:
                                InputDecoration(hintText: "Optional message"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                message = "";
                                Navigator.pop(context);
                              },
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                sendReport(message);
                                Navigator.pop(context);
                              },
                              child: Text("Send"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text("Report lack of requested medications"),
                ),
              ),

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: submitForm,
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
