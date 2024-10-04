class Paciente {
  final int nss;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String lpm;
  final double estatura;
  final double peso;
  final DateTime fechaEntrada;
  final bool habilitarVisita;
  final String estado;
  final String sexo;
  final DateTime fechaNacimiento;
  final String grupoRh;
  final int visitantes;
  final String alergias;
  final int numeroPiso;

  Paciente({
    required this.nss,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.lpm,
    required this.estatura,
    required this.peso,
    required this.fechaEntrada,
    required this.habilitarVisita,
    required this.estado,
    required this.sexo,
    required this.fechaNacimiento,
    required this.grupoRh,
    required this.visitantes,
    required this.alergias,
    required this.numeroPiso,
  });

  factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      nss: map['nss_paciente'],
      nombre: map['nombre'],
      apellidoPaterno: map['apellido_paterno'],
      apellidoMaterno: map['apellido_materno'],
      lpm: map['lpm'],
      estatura: map['estatura'],
      peso: map['peso'],
      fechaEntrada: DateTime.parse(map['fecha_entrada']),
      habilitarVisita: map['habilitar_visita'] == 1,
      estado: map['estado'],
      sexo: map['sexo'],
      fechaNacimiento: DateTime.parse(map['fecha_nacimiento']),
      grupoRh: map['gpo_y_rh'],
      visitantes: map['visitantes'],
      alergias: map['alergias'],
      numeroPiso: map['numero_piso'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nss_paciente': nss,
      'nombre': nombre,
      'apellido_paterno': apellidoPaterno,
      'apellido_materno': apellidoMaterno,
      'lpm': lpm,
      'estatura': estatura,
      'peso': peso,
      'fecha_entrada': fechaEntrada.toIso8601String(),
      'habilitar_visita': habilitarVisita ? 1 : 0,
      'estado': estado,
      'sexo': sexo,
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'gpo_y_rh': grupoRh,
      'visitantes': visitantes,
      'alergias': alergias,
      'numero_piso': numeroPiso,
    };
  }
}
