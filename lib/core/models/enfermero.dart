class Enfermero {
  final int id;
  final String horario;
  final String jerarquia;
  final int idServicio;
  final int idPersonal;

  Enfermero({
    required this.id,
    required this.horario,
    required this.jerarquia,
    required this.idServicio,
    required this.idPersonal,
  });

  factory Enfermero.fromMap(Map<String, dynamic> map) {
    return Enfermero(
      id: map['id_enfermero'],
      horario: map['horario'],
      jerarquia: map['jerarquia'],
      idServicio: map['id_servicio'],
      idPersonal: map['id_personal'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_enfermero': id,
      'horario': horario,
      'jerarquia': jerarquia,
      'id_servicio': idServicio,
      'id_personal': idPersonal,
    };
  }
}
