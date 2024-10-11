class SolicitudAHospital {
  final int id;
  final DateTime fecha;
  final String peticion;
  final int clues;
  final int idPersonal;

  SolicitudAHospital({
    required this.id,
    required this.fecha,
    required this.peticion,
    required this.clues,
    required this.idPersonal,
  });

  factory SolicitudAHospital.fromMap(Map<String, dynamic> map) {
    return SolicitudAHospital(
      id: map['id_solicitud_a_hospital'],
      fecha: DateTime.parse(map['fecha']),
      peticion: map['peticion'],
      clues: map['clues'],
      idPersonal: map['id_personal'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_solicitud_a_hospital': id,
      'fecha': fecha.toIso8601String(),
      'peticion': peticion,
      'clues': clues,
      'id_personal': idPersonal,
    };
  }
}
