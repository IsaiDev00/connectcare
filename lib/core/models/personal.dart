class Personal {
  final int id;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String tipo;
  final String correoElectronico;
  final String? contrasena;
  final String? telefono;
  final String? estatus;
  final String? asignado;
  final int? clues;
  final String firebaseUid; // Agregado

  Personal({
    required this.id,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.tipo,
    required this.correoElectronico,
    this.contrasena,
    this.telefono,
    this.estatus,
    this.asignado,
    this.clues,
    required this.firebaseUid,
  });

  factory Personal.fromMap(Map<String, dynamic> map) {
    return Personal(
      id: map['id_personal'],
      nombre: map['nombre'],
      apellidoPaterno: map['apellido_paterno'],
      apellidoMaterno: map['apellido_materno'],
      tipo: map['tipo'],
      correoElectronico: map['correo_electronico'],
      contrasena: map['contrasena'],
      telefono: map['telefono'],
      estatus: map['estatus'],
      asignado: map['asignado'],
      clues: map['clues'],
      firebaseUid: map['firebase_uid'], // Agregado
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_personal': id,
      'nombre': nombre,
      'apellido_paterno': apellidoPaterno,
      'apellido_materno': apellidoMaterno,
      'tipo': tipo,
      'correo_electronico': correoElectronico,
      'contrasena': contrasena,
      'telefono': telefono,
      'estatus': estatus,
      'asignado': asignado,
      'clues': clues,
      'firebase_uid': firebaseUid, // Agregado
    };
  }
}
