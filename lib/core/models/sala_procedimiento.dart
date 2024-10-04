class SalaProcedimiento {
  final int numeroSala;
  final int idProcedimiento;

  SalaProcedimiento({
    required this.numeroSala,
    required this.idProcedimiento,
  });

  factory SalaProcedimiento.fromMap(Map<String, dynamic> map) {
    return SalaProcedimiento(
      numeroSala: map['numero_sala'],
      idProcedimiento: map['id_procedimiento'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numero_sala': numeroSala,
      'id_procedimiento': idProcedimiento,
    };
  }
}
