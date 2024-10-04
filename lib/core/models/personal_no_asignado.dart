class PersonalNoAsignado {
  final int id;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correoElectronico;
  final String tipo;
  final String telefono;

  PersonalNoAsignado({
    required this.id,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correoElectronico,
    required this.tipo,
    required this.telefono,
  });

  factory PersonalNoAsignado.fromMap(Map<String, dynamic> map) {
    return PersonalNoAsignado(
      id: map['id_personal_no_asignado'],
      nombre: map['nombre'],
      apellidoPaterno: map['apellido_paterno'],
      apellidoMaterno: map['apellido_materno'],
      correoElectronico: map['correo_electronico'],
      tipo: map['tipo'],
      telefono: map['telefono'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_personal_no_asignado': id,
      'nombre': nombre,
      'apellido_paterno': apellidoPaterno,
      'apellido_materno': apellidoMaterno,
      'correo_electronico': correoElectronico,
      'tipo': tipo,
      'telefono': telefono,
    };
  }
}
