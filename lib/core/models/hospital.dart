class Hospital {
  final int clues;
  final String colonia;
  final String estatus;
  final String cp;
  final String calle;
  final String numeroCalle;
  final String estado;
  final String municipio;
  final String nombre;

  Hospital({
    required this.clues,
    required this.colonia,
    required this.estatus,
    required this.cp,
    required this.calle,
    required this.numeroCalle,
    required this.estado,
    required this.municipio,
    required this.nombre,
  });

  factory Hospital.fromMap(Map<String, dynamic> map) {
    return Hospital(
      clues: map['clues'],
      colonia: map['colonia'],
      estatus: map['estatus'],
      cp: map['cp'],
      calle: map['calle'],
      numeroCalle: map['numero_calle'],
      estado: map['estado'],
      municipio: map['municipio'],
      nombre: map['nombre'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clues': clues,
      'colonia': colonia,
      'estatus': estatus,
      'cp': cp,
      'calle': calle,
      'numero_calle': numeroCalle,
      'estado': estado,
      'municipio': municipio,
      'nombre': nombre,
    };
  }
}
