class Movimiento {
  final int id;
  final DateTime fecha;
  final String hora;
  final String tipo;
  final String descripcion;
  final int idPersonal;

  Movimiento({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.tipo,
    required this.descripcion,
    required this.idPersonal,
  });

  factory Movimiento.fromMap(Map<String, dynamic> map) {
    return Movimiento(
      id: map['id_movimiento'],
      fecha: DateTime.parse(map['fecha']),
      hora: map['hora'],
      tipo: map['tipo'],
      descripcion: map['descripcion'],
      idPersonal: map['id_personal'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_movimiento': id,
      'fecha': fecha.toIso8601String(),
      'hora': hora,
      'tipo': tipo,
      'descripcion': descripcion,
      'id_personal': idPersonal,
    };
  }
}
