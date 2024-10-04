class RH {
  final int id;
  final String horario;
  final int idPersonal;

  RH({
    required this.id,
    required this.horario,
    required this.idPersonal,
  });

  factory RH.fromMap(Map<String, dynamic> map) {
    return RH(
      id: map['id_rh'],
      horario: map['horario'],
      idPersonal: map['id_personal'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_rh': id,
      'horario': horario,
      'id_personal': idPersonal,
    };
  }
}
