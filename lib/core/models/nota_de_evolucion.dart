class NotaDeEvolucion {
  final int id;
  final double saturacionOxigeno;
  final double temperatura;
  final int frecuenciaCardiaca;
  final int frecuenciaRespiratoria;
  final int taDiastolica;
  final int taSistolica;
  final String evolucion;
  final String somatometria;
  final String exploracionFisica;
  final String laboratorio;
  final String imagen;
  final String diagnostico;
  final String plan;
  final String pronostico;
  final String comentario;
  final String nota;
  final String destinoHospitalario;
  final String resultadoCultivo;
  final DateTime? fechaSolicitudCultivo;
  final bool infeccionNosocomial;
  final DateTime? fechaIntubacion;
  final DateTime? fechaCateter;
  final int nssPaciente;

  NotaDeEvolucion({
    required this.id,
    required this.saturacionOxigeno,
    required this.temperatura,
    required this.frecuenciaCardiaca,
    required this.frecuenciaRespiratoria,
    required this.taDiastolica,
    required this.taSistolica,
    required this.evolucion,
    required this.somatometria,
    required this.exploracionFisica,
    required this.laboratorio,
    required this.imagen,
    required this.diagnostico,
    required this.plan,
    required this.pronostico,
    required this.comentario,
    required this.nota,
    required this.destinoHospitalario,
    required this.resultadoCultivo,
    this.fechaSolicitudCultivo,
    required this.infeccionNosocomial,
    this.fechaIntubacion,
    this.fechaCateter,
    required this.nssPaciente,
  });

  factory NotaDeEvolucion.fromMap(Map<String, dynamic> map) {
    return NotaDeEvolucion(
      id: map['id_nota_de_evolucion'],
      saturacionOxigeno: map['saturacion_oxigeno'],
      temperatura: map['temperatura'],
      frecuenciaCardiaca: map['frecuencia_cardiaca'],
      frecuenciaRespiratoria: map['frecuencia_respiratoria'],
      taDiastolica: map['ta_diastolica'],
      taSistolica: map['ta_sistolica'],
      evolucion: map['evolucion'],
      somatometria: map['somatometria'],
      exploracionFisica: map['exploracion_fisica'],
      laboratorio: map['laboratorio'],
      imagen: map['imagen'],
      diagnostico: map['diagnostico'],
      plan: map['plan'],
      pronostico: map['pronostico'],
      comentario: map['comentario'],
      nota: map['nota'],
      destinoHospitalario: map['destino_hospitalario'],
      resultadoCultivo: map['resultado_cultivo'],
      fechaSolicitudCultivo: map['fecha_solicitud_cultivo'] != null
          ? DateTime.parse(map['fecha_solicitud_cultivo'])
          : null,
      infeccionNosocomial: map['infeccion_nosocomial'] == 1,
      fechaIntubacion: map['fecha_intubacion'] != null
          ? DateTime.parse(map['fecha_intubacion'])
          : null,
      fechaCateter: map['fecha_cateter'] != null
          ? DateTime.parse(map['fecha_cateter'])
          : null,
      nssPaciente: map['nss_paciente'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_nota_de_evolucion': id,
      'saturacion_oxigeno': saturacionOxigeno,
      'temperatura': temperatura,
      'frecuencia_cardiaca': frecuenciaCardiaca,
      'frecuencia_respiratoria': frecuenciaRespiratoria,
      'ta_diastolica': taDiastolica,
      'ta_sistolica': taSistolica,
      'evolucion': evolucion,
      'somatometria': somatometria,
      'exploracion_fisica': exploracionFisica,
      'laboratorio': laboratorio,
      'imagen': imagen,
      'diagnostico': diagnostico,
      'plan': plan,
      'pronostico': pronostico,
      'comentario': comentario,
      'nota': nota,
      'destino_hospitalario': destinoHospitalario,
      'resultado_cultivo': resultadoCultivo,
      'fecha_solicitud_cultivo': fechaSolicitudCultivo?.toIso8601String(),
      'infeccion_nosocomial': infeccionNosocomial ? 1 : 0,
      'fecha_intubacion': fechaIntubacion?.toIso8601String(),
      'fecha_cateter': fechaCateter?.toIso8601String(),
      'nss_paciente': nssPaciente,
    };
  }
}
