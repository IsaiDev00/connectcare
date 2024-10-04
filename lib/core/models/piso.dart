class Piso {
  final int numeroPiso;

  Piso({
    required this.numeroPiso,
  });

  factory Piso.fromMap(Map<String, dynamic> map) {
    return Piso(
      numeroPiso: map['numero_piso'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numero_piso': numeroPiso,
    };
  }
}
