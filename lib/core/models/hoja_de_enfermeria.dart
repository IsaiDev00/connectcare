class HojaDeEnfermeria {
  final int id;
  final DateTime fecha;
  final String codigoTemperatura;
  final double temperatura;
  final String problemaInterdependiente;
  final int taSistolica;
  final int taDiastolica;
  final int frecuenciaRespiratoria;
  final int frecuenciaCardiaca;
  final double temperaturaInterna;
  final double pvc;
  final double perimetro;
  final String infusionIntravenosa;
  final String controlLiquidos;
  final String escalas;
  final String pf;
  final String signos;
  final String sintomas;
  final double peso;
  final String intervencionesColaboracion;
  final String dxMedico;
  final int nssPaciente;

  HojaDeEnfermeria({
    required this.id,
    required this.fecha,
    required this.codigoTemperatura,
    required this.temperatura,
    required this.problemaInterdependiente,
    required this.taSistolica,
    required this.taDiastolica,
    required this.frecuenciaRespiratoria,
    required this.frecuenciaCardiaca,
    required this.temperaturaInterna,
    required this.pvc,
    required this.perimetro,
    required this.infusionIntravenosa,
    required this.controlLiquidos,
    required this.escalas,
    required this.pf,
    required this.signos,
    required this.sintomas,
    required this.peso,
    required this.intervencionesColaboracion,
    required this.dxMedico,
    required this.nssPaciente,
  });

  factory HojaDeEnfermeria.fromMap(Map<String, dynamic> map) {
    return HojaDeEnfermeria(
      id: map['id_hoja_de_enfermeria'],
      fecha: DateTime.parse(map['fecha']),
      codigoTemperatura: map['codigo_temperatura'],
      temperatura: map['temperatura'],
      problemaInterdependiente: map['problema_interdependiente'],
      taSistolica: map['ta_sistolica'],
      taDiastolica: map['ta_diastolica'],
      frecuenciaRespiratoria: map['frecuencia_respiratoria'],
      frecuenciaCardiaca: map['frecuencia_cardiaca'],
      temperaturaInterna: map['temperatura_interna'],
      pvc: map['pvc'],
      perimetro: map['perimetro'],
      infusionIntravenosa: map['infusion_intravenosa'],
      controlLiquidos: map['control_liquidos'],
      escalas: map['escalas'],
      pf: map['pf'],
      signos: map['signos'],
      sintomas: map['sintomas'],
      peso: map['peso'],
      intervencionesColaboracion: map['intervenciones_colaboracion'],
      dxMedico: map['dx_medico'],
      nssPaciente: map['nss_paciente'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_hoja_de_enfermeria': id,
      'fecha': fecha.toIso8601String(),
      'codigo_temperatura': codigoTemperatura,
      'temperatura': temperatura,
      'problema_interdependiente': problemaInterdependiente,
      'ta_sistolica': taSistolica,
      'ta_diastolica': taDiastolica,
      'frecuencia_respiratoria': frecuenciaRespiratoria,
      'frecuencia_cardiaca': frecuenciaCardiaca,
      'temperatura_interna': temperaturaInterna,
      'pvc': pvc,
      'perimetro': perimetro,
      'infusion_intravenosa': infusionIntravenosa,
      'control_liquidos': controlLiquidos,
      'escalas': escalas,
      'pf': pf,
      'signos': signos,
      'sintomas': sintomas,
      'peso': peso,
      'intervenciones_colaboracion': intervencionesColaboracion,
      'dx_medico': dxMedico,
      'nss_paciente': nssPaciente,
    };
  }
}
