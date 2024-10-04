class Padecimiento {
  final int id;
  final String nombre;
  final String gravedad;
  final String periodoReposo;

  Padecimiento({
    required this.id,
    required this.nombre,
    required this.gravedad,
    required this.periodoReposo,
  });

  factory Padecimiento.fromMap(Map<String, dynamic> map) {
    return Padecimiento(
      id: map['id_padecimiento'],
      nombre: map['nombre'],
      gravedad: map['gravedad'],
      periodoReposo: map['periodo_reposo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_padecimiento': id,
      'nombre': nombre,
      'gravedad': gravedad,
      'periodo_reposo': periodoReposo,
    };
  }
}
