class Medicamento {
  final String nombre;
  final String marca;
  final String tipo;
  final int cantidadPresentacion;
  final String concentracion;
  final int cantidadStock;
  final String caducidad;
  final String clues;

  Medicamento({
    required this.nombre,
    required this.marca,
    required this.tipo,
    required this.cantidadPresentacion,
    required this.concentracion,
    required this.cantidadStock,
    required this.caducidad,
    required this.clues,
  });

  factory Medicamento.fromMap(Map<String, dynamic> map) {
    return Medicamento(
      nombre: map['nombre'],
      marca: map['marca'],
      tipo: map['tipo'],
      cantidadPresentacion: map['cantidad_presentacion'],
      concentracion: map['concentracion'],
      cantidadStock: map['cantidad_stock'],
      caducidad: map['caducidad'],
      clues: map['clues'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'marca': marca,
      'tipo': tipo,
      'cantidad_presentacion': cantidadPresentacion,
      'concentracion': concentracion,
      'cantidad_stock': cantidadStock,
      'caducidad': caducidad,
      'clues': clues,
    };
  }
}
