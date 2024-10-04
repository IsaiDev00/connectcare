class Cama {
  final int numeroCama;
  final String tipo;
  final bool enUso;
  final int numeroSala;

  Cama({
    required this.numeroCama,
    required this.tipo,
    required this.enUso,
    required this.numeroSala,
  });

  factory Cama.fromMap(Map<String, dynamic> map) {
    return Cama(
      numeroCama: map['numero_cama'],
      tipo: map['tipo'],
      enUso: map['en_uso'] == 1,
      numeroSala: map['numero_sala'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numero_cama': numeroCama,
      'tipo': tipo,
      'en_uso': enUso ? 1 : 0,
      'numero_sala': numeroSala,
    };
  }
}
