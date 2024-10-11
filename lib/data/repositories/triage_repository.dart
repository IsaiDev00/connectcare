// Repositorio para la tabla Triage
// repositories/triage_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class TriageRepository {
  // Obtener todos los registros de la tabla Triage
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM triage');

    List<Map<String, dynamic>> triages = [];
    for (var row in results) {
      triages.add({
        'id_triage': row['id_triage'],
        'diagnostico': row['diagnostico'],
        'tratamiento': row['tratamiento'],
        'g_capilar': row['g_capilar'],
        'frecuencia_respiratoria': row['frecuencia_respiratoria'],
        'frecuencia_cardiaca': row['frecuencia_cardiaca'],
        'ta_diastolica': row['ta_diastolica'],
        'ta_sistolica': row['ta_sistolica'],
        'fecha_fin': row['fecha_fin'],
        'hora_fin': row['hora_fin'],
        'fecha_inicio': row['fecha_inicio'],
        'hora_inicio': row['hora_inicio'],
        'temperatura': row['temperatura'],
        'peso': row['peso'],
        'estatura': row['estatura'],
        'escala_glasgow': row['escala_glasgow'],
        'gravedad': row['gravedad'],
        'motivo': row['motivo'],
        'interrogatorio': row['interrogatorio'],
        'exploracion_fisica': row['exploracion_fisica'],
        'auxiliares_diagnostico': row['auxiliares_diagnostico'],
        'nss_paciente': row['nss_paciente'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return triages;
  }

  // Obtener un registro por ID de la tabla Triage
  Future<Map<String, dynamic>?> getById(int idTriage) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn
        .query('SELECT * FROM triage WHERE id_triage = ?', [idTriage]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_triage': row['id_triage'],
        'diagnostico': row['diagnostico'],
        'tratamiento': row['tratamiento'],
        'g_capilar': row['g_capilar'],
        'frecuencia_respiratoria': row['frecuencia_respiratoria'],
        'frecuencia_cardiaca': row['frecuencia_cardiaca'],
        'ta_diastolica': row['ta_diastolica'],
        'ta_sistolica': row['ta_sistolica'],
        'fecha_fin': row['fecha_fin'],
        'hora_fin': row['hora_fin'],
        'fecha_inicio': row['fecha_inicio'],
        'hora_inicio': row['hora_inicio'],
        'temperatura': row['temperatura'],
        'peso': row['peso'],
        'estatura': row['estatura'],
        'escala_glasgow': row['escala_glasgow'],
        'gravedad': row['gravedad'],
        'motivo': row['motivo'],
        'interrogatorio': row['interrogatorio'],
        'exploracion_fisica': row['exploracion_fisica'],
        'auxiliares_diagnostico': row['auxiliares_diagnostico'],
        'nss_paciente': row['nss_paciente'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Triage
  Future<void> insert(Map<String, dynamic> triage) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO triage (diagnostico, tratamiento, g_capilar, frecuencia_respiratoria, frecuencia_cardiaca, ta_diastolica, ta_sistolica, fecha_fin, hora_fin, fecha_inicio, hora_inicio, temperatura, peso, estatura, escala_glasgow, gravedad, motivo, interrogatorio, exploracion_fisica, auxiliares_diagnostico, nss_paciente) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        triage['diagnostico'],
        triage['tratamiento'],
        triage['g_capilar'],
        triage['frecuencia_respiratoria'],
        triage['frecuencia_cardiaca'],
        triage['ta_diastolica'],
        triage['ta_sistolica'],
        triage['fecha_fin'],
        triage['hora_fin'],
        triage['fecha_inicio'],
        triage['hora_inicio'],
        triage['temperatura'],
        triage['peso'],
        triage['estatura'],
        triage['escala_glasgow'],
        triage['gravedad'],
        triage['motivo'],
        triage['interrogatorio'],
        triage['exploracion_fisica'],
        triage['auxiliares_diagnostico'],
        triage['nss_paciente'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Triage
  Future<void> update(int idTriage, Map<String, dynamic> triage) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE triage SET diagnostico = ?, tratamiento = ?, g_capilar = ?, frecuencia_respiratoria = ?, frecuencia_cardiaca = ?, ta_diastolica = ?, ta_sistolica = ?, fecha_fin = ?, hora_fin = ?, fecha_inicio = ?, hora_inicio = ?, temperatura = ?, peso = ?, estatura = ?, escala_glasgow = ?, gravedad = ?, motivo = ?, interrogatorio = ?, exploracion_fisica = ?, auxiliares_diagnostico = ?, nss_paciente = ? WHERE id_triage = ?',
      [
        triage['diagnostico'],
        triage['tratamiento'],
        triage['g_capilar'],
        triage['frecuencia_respiratoria'],
        triage['frecuencia_cardiaca'],
        triage['ta_diastolica'],
        triage['ta_sistolica'],
        triage['fecha_fin'],
        triage['hora_fin'],
        triage['fecha_inicio'],
        triage['hora_inicio'],
        triage['temperatura'],
        triage['peso'],
        triage['estatura'],
        triage['escala_glasgow'],
        triage['gravedad'],
        triage['motivo'],
        triage['interrogatorio'],
        triage['exploracion_fisica'],
        triage['auxiliares_diagnostico'],
        triage['nss_paciente'],
        idTriage,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Triage
  Future<void> delete(int idTriage) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query('DELETE FROM triage WHERE id_triage = ?', [idTriage]);
    await DatabaseHelper.closeConnection(conn);
  }
}
