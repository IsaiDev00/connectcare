class TrabajoSocial {
  final int id;
  final String horario;
  final int idPersonal;

  TrabajoSocial({
    required this.id,
    required this.horario,
    required this.idPersonal,
  });

  factory TrabajoSocial.fromMap(Map<String, dynamic> map) {
    return TrabajoSocial(
      id: map['id_trabajo_social'],
      horario: map['horario'],
      idPersonal: map['id_personal'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_trabajo_social': id,
      'horario': horario,
      'id_personal': idPersonal,
    };
  }
}
