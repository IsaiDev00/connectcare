class Procedimiento {
  final int id;
  final String nombre;
  final String descripcion;
  final int cantidadEnfermeros;
  final int cantidadMedicos;

  Procedimiento({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.cantidadEnfermeros,
    required this.cantidadMedicos,
  });

  factory Procedimiento.fromMap(Map<String, dynamic> map) {
    return Procedimiento(
      id: map['id_procedimiento'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      cantidadEnfermeros: map['cantidad_enfermeros'],
      cantidadMedicos: map['cantidad_medicos'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_procedimiento': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'cantidad_enfermeros': cantidadEnfermeros,
      'cantidad_medicos': cantidadMedicos,
    };
  }
}
