class Administrador {
  final int id;
  final String horario;
  final int clues;
  final int idPersonal;

  Administrador({
    required this.id,
    required this.horario,
    required this.clues,
    required this.idPersonal,
  });

  factory Administrador.fromMap(Map<String, dynamic> map) {
    return Administrador(
      id: map['id_administrador'],
      horario: map['horario'],
      clues: map['clues'],
      idPersonal: map['id_personal'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_administrador': id,
      'horario': horario,
      'clues': clues,
      'id_personal': idPersonal,
    };
  }
}
