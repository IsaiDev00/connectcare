class Familiar {
  final int id;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correoElectronico;
  final String contrasena;
  final String telefono;
  final String tipo;

  Familiar({
    required this.id,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correoElectronico,
    required this.contrasena,
    required this.telefono,
    required this.tipo,
  });

  factory Familiar.fromMap(Map<String, dynamic> map) {
    return Familiar(
      id: map['id_familiar'],
      nombre: map['nombre'],
      apellidoPaterno: map['apellido_paterno'],
      apellidoMaterno: map['apellido_materno'],
      correoElectronico: map['correo_electronico'],
      contrasena: map['contrasena'],
      telefono: map['telefono'],
      tipo: map['tipo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_familiar': id,
      'nombre': nombre,
      'apellido_paterno': apellidoPaterno,
      'apellido_materno': apellidoMaterno,
      'correo_electronico': correoElectronico,
      'contrasena': contrasena,
      'telefono': telefono,
      'tipo': tipo,
    };
  }
}
