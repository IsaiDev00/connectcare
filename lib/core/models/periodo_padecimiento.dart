class PeriodoPadecimiento {
  final int id;
  final String periodoReposo;
  final int edad;
  final String gravedad;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  PeriodoPadecimiento({
    required this.id,
    required this.periodoReposo,
    required this.edad,
    required this.gravedad,
    required this.fechaInicio,
    required this.fechaFin,
  });

  factory PeriodoPadecimiento.fromMap(Map<String, dynamic> map) {
    return PeriodoPadecimiento(
      id: map['id_periodo_padecimiento'],
      periodoReposo: map['periodo_reposo'],
      edad: map['edad'],
      gravedad: map['gravedad'],
      fechaInicio: DateTime.parse(map['f_inicio']),
      fechaFin: DateTime.parse(map['f_fin']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_periodo_padecimiento': id,
      'periodo_reposo': periodoReposo,
      'edad': edad,
      'gravedad': gravedad,
      'f_inicio': fechaInicio.toIso8601String(),
      'f_fin': fechaFin.toIso8601String(),
    };
  }
}
