class Historial {
  final int id;
  final int nssPaciente;
  final int idTraslado;
  final int idProcedimiento;
  final int idIndicacionesMedicas;
  final int idNotaDeEvolucion;
  final int idHojaDeEnfermeria;
  final int idTriage;

  Historial({
    required this.id,
    required this.nssPaciente,
    required this.idTraslado,
    required this.idProcedimiento,
    required this.idIndicacionesMedicas,
    required this.idNotaDeEvolucion,
    required this.idHojaDeEnfermeria,
    required this.idTriage,
  });

  factory Historial.fromMap(Map<String, dynamic> map) {
    return Historial(
      id: map['id_historial'],
      nssPaciente: map['nss_paciente'],
      idTraslado: map['id_traslado'],
      idProcedimiento: map['id_procedimiento'],
      idIndicacionesMedicas: map['id_indicaciones_medicas'],
      idNotaDeEvolucion: map['id_nota_de_evolucion'],
      idHojaDeEnfermeria: map['id_hoja_de_enfermeria'],
      idTriage: map['id_triage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_historial': id,
      'nss_paciente': nssPaciente,
      'id_traslado': idTraslado,
      'id_procedimiento': idProcedimiento,
      'id_indicaciones_medicas': idIndicacionesMedicas,
      'id_nota_de_evolucion': idNotaDeEvolucion,
      'id_hoja_de_enfermeria': idHojaDeEnfermeria,
      'id_triage': idTriage,
    };
  }
}
