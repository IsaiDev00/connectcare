class Servicio {
  final int id;
  final String nombre;
  final int numeroPiso;

  Servicio({
    required this.id,
    required this.nombre,
    required this.numeroPiso,
  });

  factory Servicio.fromMap(Map<String, dynamic> map) {
    return Servicio(
      id: map['id_servicio'],
      nombre: map['nombre'],
      numeroPiso: map['numero_piso'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_servicio': id,
      'nombre': nombre,
      'numero_piso': numeroPiso,
    };
  }
}
