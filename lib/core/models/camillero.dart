class Camillero {
  final int id;
  final String jerarquia;
  final String horario;
  final int idServicio;
  final int idPersonal;

  Camillero({
    required this.id,
    required this.jerarquia,
    required this.horario,
    required this.idServicio,
    required this.idPersonal,
  });

  factory Camillero.fromMap(Map<String, dynamic> map) {
    return Camillero(
      id: map['id_camillero'],
      jerarquia: map['jerarquia'],
      horario: map['horario'],
      idServicio: map['id_servicio'],
      idPersonal: map['id_personal'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_camillero': id,
      'jerarquia': jerarquia,
      'horario': horario,
      'id_servicio': idServicio,
      'id_personal': idPersonal,
    };
  }
}
