class Triage {
  final int id;
  final String diagnostico;
  final String tratamiento;
  final double gCapilar;
  final int frecuenciaRespiratoria;
  final int frecuenciaCardiaca;
  final int taDiastolica;
  final int taSistolica;
  final DateTime fechaFin;
  final String horaFin;
  final DateTime fechaInicio;
  final String horaInicio;
  final double temperatura;
  final double peso;
  final double estatura;
  final int escalaGlasgow;
  final String gravedad;
  final String motivo;
  final String interrogatorio;
  final String exploracionFisica;
  final String auxiliaresDiagnostico;
  final int nssPaciente;

  Triage({
    required this.id,
    required this.diagnostico,
    required this.tratamiento,
    required this.gCapilar,
    required this.frecuenciaRespiratoria,
    required this.frecuenciaCardiaca,
    required this.taDiastolica,
    required this.taSistolica,
    required this.fechaFin,
    required this.horaFin,
    required this.fechaInicio,
    required this.horaInicio,
    required this.temperatura,
    required this.peso,
    required this.estatura,
    required this.escalaGlasgow,
    required this.gravedad,
    required this.motivo,
    required this.interrogatorio,
    required this.exploracionFisica,
    required this.auxiliaresDiagnostico,
    required this.nssPaciente,
  });

  factory Triage.fromMap(Map<String, dynamic> map) {
    return Triage(
      id: map['id_triage'],
      diagnostico: map['diagnostico'],
      tratamiento: map['tratamiento'],
      gCapilar: map['g_capilar'],
      frecuenciaRespiratoria: map['frecuencia_respiratoria'],
      frecuenciaCardiaca: map['frecuencia_cardiaca'],
      taDiastolica: map['ta_diastolica'],
      taSistolica: map['ta_sistolica'],
      fechaFin: DateTime.parse(map['fecha_fin']),
      horaFin: map['hora_fin'],
      fechaInicio: DateTime.parse(map['fecha_inicio']),
      horaInicio: map['hora_inicio'],
      temperatura: map['temperatura'],
      peso: map['peso'],
      estatura: map['estatura'],
      escalaGlasgow: map['escala_glasgow'],
      gravedad: map['gravedad'],
      motivo: map['motivo'],
      interrogatorio: map['interrogatorio'],
      exploracionFisica: map['exploracion_fisica'],
      auxiliaresDiagnostico: map['auxiliares_diagnostico'],
      nssPaciente: map['nss_paciente'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_triage': id,
      'diagnostico': diagnostico,
      'tratamiento': tratamiento,
      'g_capilar': gCapilar,
      'frecuencia_respiratoria': frecuenciaRespiratoria,
      'frecuencia_cardiaca': frecuenciaCardiaca,
      'ta_diastolica': taDiastolica,
      'ta_sistolica': taSistolica,
      'fecha_fin': fechaFin.toIso8601String(),
      'hora_fin': horaFin,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'hora_inicio': horaInicio,
      'temperatura': temperatura,
      'peso': peso,
      'estatura': estatura,
      'escala_glasgow': escalaGlasgow,
      'gravedad': gravedad,
      'motivo': motivo,
      'interrogatorio': interrogatorio,
      'exploracion_fisica': exploracionFisica,
      'auxiliares_diagnostico': auxiliaresDiagnostico,
      'nss_paciente': nssPaciente,
    };
  }
}
