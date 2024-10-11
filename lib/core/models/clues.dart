class Clues {
  final String clues;
  final String nombreInstitucion;
  final String entidad;
  final String municipio;
  final String estatusOperacion;
  final String codigoPostal;
  final String vialidad;
  final String numeroExterior;
  final String tipoVialidad;
  final String tipoAsentamiento;
  final String asentamiento;

  Clues({
    required this.clues,
    required this.nombreInstitucion,
    required this.entidad,
    required this.municipio,
    required this.estatusOperacion,
    required this.codigoPostal,
    required this.vialidad,
    required this.numeroExterior,
    required this.tipoVialidad,
    required this.tipoAsentamiento,
    required this.asentamiento,
  });

  factory Clues.fromMap(Map<String, dynamic> map) {
    return Clues(
      clues: map['clues'],
      nombreInstitucion: map['nombre_institucion'],
      entidad: map['entidad'],
      municipio: map['municipio'],
      estatusOperacion: map['estatus_operacion'],
      codigoPostal: map['codigo_postal'],
      vialidad: map['vialidad'],
      numeroExterior: map['numero_exterior'],
      tipoVialidad: map['tipo_vialidad'],
      tipoAsentamiento: map['tipo_asentamiento'],
      asentamiento: map['asentamiento'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clues': clues,
      'nombre_institucion': nombreInstitucion,
      'entidad': entidad,
      'municipio': municipio,
      'estatus_operacion': estatusOperacion,
      'codigo_postal': codigoPostal,
      'vialidad': vialidad,
      'numero_exterior': numeroExterior,
      'tipo_vialidad': tipoVialidad,
      'tipo_asentamiento': tipoAsentamiento,
      'asentamiento': asentamiento,
    };
  }
}