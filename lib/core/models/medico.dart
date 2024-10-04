class Medico {
  final int id;
  final String especialidad;
  final String jerarquia;
  final String horario;
  final int idServicio;
  final int idPersonal;

  Medico({
    required this.id,
    required this.especialidad,
    required this.jerarquia,
    required this.horario,
    required this.idServicio,
    required this.idPersonal,
  });

  factory Medico.fromMap(Map<String, dynamic> map) {
    return Medico(
      id: map['id_medico'],
      especialidad: map['especialidad'],
      jerarquia: map['jerarquia'],
      horario: map['horario'],
      idServicio: map['id_servicio'],
      idPersonal: map['id_personal'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_medico': id,
      'especialidad': especialidad,
      'jerarquia': jerarquia,
      'horario': horario,
      'id_servicio': idServicio,
      'id_personal': idPersonal,
    };
  }
}
