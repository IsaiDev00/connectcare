class Sala {
  final int numeroSala;
  final String horario;
  final String nombre;
  final bool lleno;
  final int idServicio;

  Sala({
    required this.numeroSala,
    required this.horario,
    required this.nombre,
    required this.lleno,
    required this.idServicio,
  });

  factory Sala.fromMap(Map<String, dynamic> map) {
    return Sala(
      numeroSala: map['numero_sala'],
      horario: map['horario'],
      nombre: map['nombre'],
      lleno: map['lleno'] == 1,
      idServicio: map['id_servicio'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numero_sala': numeroSala,
      'horario': horario,
      'nombre': nombre,
      'lleno': lleno ? 1 : 0,
      'id_servicio': idServicio,
    };
  }
}
