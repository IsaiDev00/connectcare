class HorarioVisita {
  final int id;
  final String inicio;
  final String fin;
  final int visitantes;
  final int idSala;

  HorarioVisita({
    required this.id,
    required this.inicio,
    required this.fin,
    required this.visitantes,
    required this.idSala,
  });

  factory HorarioVisita.fromMap(Map<String, dynamic> map) {
    return HorarioVisita(
      id: map['id_horario_visita'],
      inicio: map['inicio'],
      fin: map['fin'],
      visitantes: map['visitantes'],
      idSala: map['id_sala'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_horario_visita': id,
      'inicio': inicio,
      'fin': fin,
      'visitantes': visitantes,
      'id_sala': idSala,
    };
  }
}
