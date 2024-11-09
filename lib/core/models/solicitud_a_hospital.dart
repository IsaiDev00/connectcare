class SolicitudAHospital {
  final String fecha;
  final String peticion;
  final String clues;
  final int idPersonal;

  SolicitudAHospital({
    required this.fecha,
    required this.peticion,
    required this.clues,
    required this.idPersonal,
  });

  factory SolicitudAHospital.fromMap(Map<String, dynamic> map) {
    return SolicitudAHospital(
      fecha: map['fecha'],
      peticion: map['peticion'],
      clues: map['clues'],
      idPersonal: map['id_personal'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fecha': fecha,
      'peticion': peticion,
      'clues': clues,
      'id_personal': idPersonal,
    };
  }
}
