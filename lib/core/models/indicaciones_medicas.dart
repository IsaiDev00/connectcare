class IndicacionesMedicas {
  final int id;
  final String solicitudMedicamento;
  final String formula;
  final String nutricion;
  final String soluciones;
  final String lntp;
  final String indicaciones;
  final String diagnostico;
  final String lve;
  final String ret;
  final DateTime fecha;
  final String medidas;
  final String pendientes;
  final String cuidados;
  final int nssPaciente;

  IndicacionesMedicas({
    required this.id,
    required this.solicitudMedicamento,
    required this.formula,
    required this.nutricion,
    required this.soluciones,
    required this.lntp,
    required this.indicaciones,
    required this.diagnostico,
    required this.lve,
    required this.ret,
    required this.fecha,
    required this.medidas,
    required this.pendientes,
    required this.cuidados,
    required this.nssPaciente,
  });

  factory IndicacionesMedicas.fromMap(Map<String, dynamic> map) {
    return IndicacionesMedicas(
      id: map['id_indicaciones_medicas'],
      solicitudMedicamento: map['solicitud_medicamento'],
      formula: map['formula'],
      nutricion: map['nutricion'],
      soluciones: map['soluciones'],
      lntp: map['lntp'],
      indicaciones: map['indicaciones'],
      diagnostico: map['diagnostico'],
      lve: map['lve'],
      ret: map['ret'],
      fecha: DateTime.parse(map['fecha']),
      medidas: map['medidas'],
      pendientes: map['pendientes'],
      cuidados: map['cuidados'],
      nssPaciente: map['nss_paciente'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_indicaciones_medicas': id,
      'solicitud_medicamento': solicitudMedicamento,
      'formula': formula,
      'nutricion': nutricion,
      'soluciones': soluciones,
      'lntp': lntp,
      'indicaciones': indicaciones,
      'diagnostico': diagnostico,
      'lve': lve,
      'ret': ret,
      'fecha': fecha.toIso8601String(),
      'medidas': medidas,
      'pendientes': pendientes,
      'cuidados': cuidados,
      'nss_paciente': nssPaciente,
    };
  }
}
