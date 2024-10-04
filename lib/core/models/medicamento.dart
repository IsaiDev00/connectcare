class Medicamento {
  final int id;
  final String nombre;
  final String marca;
  final String tipo;
  final int cantidadPresentacion;
  final String concentracion;
  final int cantidadStock;
  final DateTime caducidad;
  final int idAdministrador;

  Medicamento({
    required this.id,
    required this.nombre,
    required this.marca,
    required this.tipo,
    required this.cantidadPresentacion,
    required this.concentracion,
    required this.cantidadStock,
    required this.caducidad,
    required this.idAdministrador,
  });

  factory Medicamento.fromMap(Map<String, dynamic> map) {
    return Medicamento(
      id: map['id_medicamento'],
      nombre: map['nombre'],
      marca: map['marca'],
      tipo: map['tipo'],
      cantidadPresentacion: map['cantidad_presentacion'],
      concentracion: map['concentracion'],
      cantidadStock: map['cantidad_stock'],
      caducidad: DateTime.parse(map['caducidad']),
      idAdministrador: map['id_administrador'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_medicamento': id,
      'nombre': nombre,
      'marca': marca,
      'tipo': tipo,
      'cantidad_presentacion': cantidadPresentacion,
      'concentracion': concentracion,
      'cantidad_stock': cantidadStock,
      'caducidad': caducidad.toIso8601String(),
      'id_administrador': idAdministrador,
    };
  }
}
