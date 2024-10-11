// Repositorio para la tabla Hoja_De_Enfermeria
// repositories/hoja_de_enfermeria_repository.dart
import 'package:mysql1/mysql1.dart';
import '../../providers/database_helper.dart';

class HojaDeEnfermeriaRepository {
  // Obtener todos los registros de la tabla Hoja_De_Enfermeria
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM hoja_de_enfermeria');

    List<Map<String, dynamic>> hojasDeEnfermeria = [];
    for (var row in results) {
      hojasDeEnfermeria.add({
        'id_hoja_de_enfermeria': row['id_hoja_de_enfermeria'],
        'fecha': row['fecha'],
        'codigo_temperatura': row['codigo_temperatura'],
        'temperatura': row['temperatura'],
        'problema_interdependiente': row['problema_interdependiente'],
        'ta_sistolica': row['ta_sistolica'],
        'ta_diastolica': row['ta_diastolica'],
        'frecuencia_respiratoria': row['frecuencia_respiratoria'],
        'frecuencia_cardiaca': row['frecuencia_cardiaca'],
        'temperatura_interna': row['temperatura_interna'],
        'pvc': row['pvc'],
        'perimetro': row['perimetro'],
        'infusion_intravenosa': row['infusion_intravenosa'],
        'control_liquidos': row['control_liquidos'],
        'escalas': row['escalas'],
        'pf': row['pf'],
        'signos': row['signos'],
        'sintomas': row['sintomas'],
        'peso': row['peso'],
        'intervenciones_colaboracion': row['intervenciones_colaboracion'],
        'dx_medico': row['dx_medico'],
        'nss_paciente': row['nss_paciente'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return hojasDeEnfermeria;
  }

  // Obtener un registro por ID de la tabla Hoja_De_Enfermeria
  Future<Map<String, dynamic>?> getById(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query(
        'SELECT * FROM hoja_de_enfermeria WHERE id_hoja_de_enfermeria = ?',
        [id]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_hoja_de_enfermeria': row['id_hoja_de_enfermeria'],
        'fecha': row['fecha'],
        'codigo_temperatura': row['codigo_temperatura'],
        'temperatura': row['temperatura'],
        'problema_interdependiente': row['problema_interdependiente'],
        'ta_sistolica': row['ta_sistolica'],
        'ta_diastolica': row['ta_diastolica'],
        'frecuencia_respiratoria': row['frecuencia_respiratoria'],
        'frecuencia_cardiaca': row['frecuencia_cardiaca'],
        'temperatura_interna': row['temperatura_interna'],
        'pvc': row['pvc'],
        'perimetro': row['perimetro'],
        'infusion_intravenosa': row['infusion_intravenosa'],
        'control_liquidos': row['control_liquidos'],
        'escalas': row['escalas'],
        'pf': row['pf'],
        'signos': row['signos'],
        'sintomas': row['sintomas'],
        'peso': row['peso'],
        'intervenciones_colaboracion': row['intervenciones_colaboracion'],
        'dx_medico': row['dx_medico'],
        'nss_paciente': row['nss_paciente'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Hoja_De_Enfermeria
  Future<void> insert(Map<String, dynamic> hojaDeEnfermeria) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO hoja_de_enfermeria (fecha, codigo_temperatura, temperatura, problema_interdependiente, ta_sistolica, ta_diastolica, frecuencia_respiratoria, frecuencia_cardiaca, temperatura_interna, pvc, perimetro, infusion_intravenosa, control_liquidos, escalas, pf, signos, sintomas, peso, intervenciones_colaboracion, dx_medico, nss_paciente) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        hojaDeEnfermeria['fecha'],
        hojaDeEnfermeria['codigo_temperatura'],
        hojaDeEnfermeria['temperatura'],
        hojaDeEnfermeria['problema_interdependiente'],
        hojaDeEnfermeria['ta_sistolica'],
        hojaDeEnfermeria['ta_diastolica'],
        hojaDeEnfermeria['frecuencia_respiratoria'],
        hojaDeEnfermeria['frecuencia_cardiaca'],
        hojaDeEnfermeria['temperatura_interna'],
        hojaDeEnfermeria['pvc'],
        hojaDeEnfermeria['perimetro'],
        hojaDeEnfermeria['infusion_intravenosa'],
        hojaDeEnfermeria['control_liquidos'],
        hojaDeEnfermeria['escalas'],
        hojaDeEnfermeria['pf'],
        hojaDeEnfermeria['signos'],
        hojaDeEnfermeria['sintomas'],
        hojaDeEnfermeria['peso'],
        hojaDeEnfermeria['intervenciones_colaboracion'],
        hojaDeEnfermeria['dx_medico'],
        hojaDeEnfermeria['nss_paciente'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Hoja_De_Enfermeria
  Future<void> update(int id, Map<String, dynamic> hojaDeEnfermeria) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE hoja_de_enfermeria SET fecha = ?, codigo_temperatura = ?, temperatura = ?, problema_interdependiente = ?, ta_sistolica = ?, ta_diastolica = ?, frecuencia_respiratoria = ?, frecuencia_cardiaca = ?, temperatura_interna = ?, pvc = ?, perimetro = ?, infusion_intravenosa = ?, control_liquidos = ?, escalas = ?, pf = ?, signos = ?, sintomas = ?, peso = ?, intervenciones_colaboracion = ?, dx_medico = ?, nss_paciente = ? WHERE id_hoja_de_enfermeria = ?',
      [
        hojaDeEnfermeria['fecha'],
        hojaDeEnfermeria['codigo_temperatura'],
        hojaDeEnfermeria['temperatura'],
        hojaDeEnfermeria['problema_interdependiente'],
        hojaDeEnfermeria['ta_sistolica'],
        hojaDeEnfermeria['ta_diastolica'],
        hojaDeEnfermeria['frecuencia_respiratoria'],
        hojaDeEnfermeria['frecuencia_cardiaca'],
        hojaDeEnfermeria['temperatura_interna'],
        hojaDeEnfermeria['pvc'],
        hojaDeEnfermeria['perimetro'],
        hojaDeEnfermeria['infusion_intravenosa'],
        hojaDeEnfermeria['control_liquidos'],
        hojaDeEnfermeria['escalas'],
        hojaDeEnfermeria['pf'],
        hojaDeEnfermeria['signos'],
        hojaDeEnfermeria['sintomas'],
        hojaDeEnfermeria['peso'],
        hojaDeEnfermeria['intervenciones_colaboracion'],
        hojaDeEnfermeria['dx_medico'],
        hojaDeEnfermeria['nss_paciente'],
        id,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Hoja_De_Enfermeria
  Future<void> delete(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
        'DELETE FROM hoja_de_enfermeria WHERE id_hoja_de_enfermeria = ?', [id]);
    await DatabaseHelper.closeConnection(conn);
  }
}
