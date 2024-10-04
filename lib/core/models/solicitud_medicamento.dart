class SolicitudMedicamento {
  final int id;
  final String concentracion;
  final int cantidadPresentacion;
  final String nombre;
  final String marca;
  final String tipo;
  final int idHojaDeEnfermeria;

  SolicitudMedicamento({
    required this.id,
    required this.concentracion,
    required this.cantidadPresentacion,
    required this.nombre,
    required this.marca,
    required this.tipo,
    required this.idHojaDeEnfermeria,
  });

  factory SolicitudMedicamento.fromMap(Map<String, dynamic> map) {
    return SolicitudMedicamento(
      id: map['id_solicitud_medicamento'],
      concentracion: map['concentracion'],
      cantidadPresentacion: map['cantidad_presentacion'],
      nombre: map['nombre'],
      marca: map['marca'],
      tipo: map['tipo'],
      idHojaDeEnfermeria: map['id_hoja_de_enfermeria'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_solicitud_medicamento': id,
      'concentracion': concentracion,
      'cantidad_presentacion': cantidadPresentacion,
      'nombre': nombre,
      'marca': marca,
      'tipo': tipo,
      'id_hoja_de_enfermeria': idHojaDeEnfermeria,
    };
  }
}
