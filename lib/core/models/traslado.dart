class Traslado {
  final int id;
  final DateTime fecha;
  final String hora;
  final int nssPaciente;
  final int numeroCama;

  Traslado({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.nssPaciente,
    required this.numeroCama,
  });

  factory Traslado.fromMap(Map<String, dynamic> map) {
    return Traslado(
      id: map['id_traslado'],
      fecha: DateTime.parse(map['fecha']),
      hora: map['hora'],
      nssPaciente: map['nss_paciente'],
      numeroCama: map['numero_cama'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_traslado': id,
      'fecha': fecha.toIso8601String(),
      'hora': hora,
      'nss_paciente': nssPaciente,
      'numero_cama': numeroCama,
    };
  }
}
