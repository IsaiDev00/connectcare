class UsoMedicamento {
  final int id;
  final int cantidad;
  final int idMedicamento;
  final int idHojaDeEnfermeria;

  UsoMedicamento({
    required this.id,
    required this.cantidad,
    required this.idMedicamento,
    required this.idHojaDeEnfermeria,
  });

  factory UsoMedicamento.fromMap(Map<String, dynamic> map) {
    return UsoMedicamento(
      id: map['id_uso_medicamento'],
      cantidad: map['cantidad'],
      idMedicamento: map['id_medicamento'],
      idHojaDeEnfermeria: map['id_hoja_de_enfermeria'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_uso_medicamento': id,
      'cantidad': cantidad,
      'id_medicamento': idMedicamento,
      'id_hoja_de_enfermeria': idHojaDeEnfermeria,
    };
  }
}
