class PacienteFamiliar {
  final int nssPaciente;
  final int idFamiliar;
  final DateTime fecha;
  final String relacion;
  final int idTrabajoSocial;

  PacienteFamiliar({
    required this.nssPaciente,
    required this.idFamiliar,
    required this.fecha,
    required this.relacion,
    required this.idTrabajoSocial,
  });

  factory PacienteFamiliar.fromMap(Map<String, dynamic> map) {
    return PacienteFamiliar(
      nssPaciente: map['nss_paciente'],
      idFamiliar: map['id_familiar'],
      fecha: DateTime.parse(map['fecha']),
      relacion: map['relacion'],
      idTrabajoSocial: map['id_trabajo_social'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nss_paciente': nssPaciente,
      'id_familiar': idFamiliar,
      'fecha': fecha.toIso8601String(),
      'relacion': relacion,
      'id_trabajo_social': idTrabajoSocial,
    };
  }
}
