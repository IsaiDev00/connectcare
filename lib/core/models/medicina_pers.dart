class MedicinaPers {
  final int id;
  final int idSolicitudMedicamento;
  final String concentracion;
  final DateTime caducidad;
  final int cantidadStock;
  final String tipo;
  final String marca;
  final String nombre;
  final int cantidadPresentacion;
  final int nssPaciente;

  MedicinaPers({
    required this.id,
    required this.idSolicitudMedicamento,
    required this.concentracion,
    required this.caducidad,
    required this.cantidadStock,
    required this.tipo,
    required this.marca,
    required this.nombre,
    required this.cantidadPresentacion,
    required this.nssPaciente,
  });

  factory MedicinaPers.fromMap(Map<String, dynamic> map) {
    return MedicinaPers(
      id: map['id_medicina_pers'],
      idSolicitudMedicamento: map['id_solicitud_medicamento'],
      concentracion: map['concentracion'],
      caducidad: DateTime.parse(map['caducidad']),
      cantidadStock: map['cantidad_stock'],
      tipo: map['tipo'],
      marca: map['marca'],
      nombre: map['nombre'],
      cantidadPresentacion: map['cantidad_presentacion'],
      nssPaciente: map['nss_paciente'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_medicina_pers': id,
      'id_solicitud_medicamento': idSolicitudMedicamento,
      'concentracion': concentracion,
      'caducidad': caducidad.toIso8601String(),
      'cantidad_stock': cantidadStock,
      'tipo': tipo,
      'marca': marca,
      'nombre': nombre,
      'cantidad_presentacion': cantidadPresentacion,
      'nss_paciente': nssPaciente,
    };
  }
}
