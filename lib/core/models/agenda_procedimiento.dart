class AgendaProcedimiento {
  final int id;
  final DateTime fecha;
  final String hora;
  final int idProcedimiento;

  AgendaProcedimiento({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.idProcedimiento,
  });

  factory AgendaProcedimiento.fromMap(Map<String, dynamic> map) {
    return AgendaProcedimiento(
      id: map['id_agenda_procedimiento'],
      fecha: DateTime.parse(map['fecha']),
      hora: map['hora'],
      idProcedimiento: map['id_procedimiento'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_agenda_procedimiento': id,
      'fecha': fecha.toIso8601String(),
      'hora': hora,
      'id_procedimiento': idProcedimiento,
    };
  }
}
