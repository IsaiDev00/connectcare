// Repositorio para la tabla Historial
// repositories/historial_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class HistorialRepository {
  // Obtener todos los registros de la tabla Historial
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM Historial');

    List<Map<String, dynamic>> historiales = [];
    for (var row in results) {
      historiales.add({
        'id_historial': row['id_historial'],
        'nss_paciente': row['nss_paciente'],
        'id_traslado': row['id_traslado'],
        'id_procedimiento': row['id_procedimiento'],
        'id_indicaciones_medicas': row['id_indicaciones_medicas'],
        'id_nota_de_evolucion': row['id_nota_de_evolucion'],
        'id_hoja_de_enfermeria': row['id_hoja_de_enfermeria'],
        'id_triage': row['id_triage'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return historiales;
  }

  // Obtener un registro por ID de la tabla Historial
  Future<Map<String, dynamic>?> getById(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn
        .query('SELECT * FROM Historial WHERE id_historial = ?', [id]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_historial': row['id_historial'],
        'nss_paciente': row['nss_paciente'],
        'id_traslado': row['id_traslado'],
        'id_procedimiento': row['id_procedimiento'],
        'id_indicaciones_medicas': row['id_indicaciones_medicas'],
        'id_nota_de_evolucion': row['id_nota_de_evolucion'],
        'id_hoja_de_enfermeria': row['id_hoja_de_enfermeria'],
        'id_triage': row['id_triage'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Historial
  Future<void> insert(Map<String, dynamic> historial) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO Historial (nss_paciente, id_traslado, id_procedimiento, id_indicaciones_medicas, id_nota_de_evolucion, id_hoja_de_enfermeria, id_triage) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        historial['nss_paciente'],
        historial['id_traslado'],
        historial['id_procedimiento'],
        historial['id_indicaciones_medicas'],
        historial['id_nota_de_evolucion'],
        historial['id_hoja_de_enfermeria'],
        historial['id_triage'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Historial
  Future<void> update(int id, Map<String, dynamic> historial) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE Historial SET nss_paciente = ?, id_traslado = ?, id_procedimiento = ?, id_indicaciones_medicas = ?, id_nota_de_evolucion = ?, id_hoja_de_enfermeria = ?, id_triage = ? WHERE id_historial = ?',
      [
        historial['nss_paciente'],
        historial['id_traslado'],
        historial['id_procedimiento'],
        historial['id_indicaciones_medicas'],
        historial['id_nota_de_evolucion'],
        historial['id_hoja_de_enfermeria'],
        historial['id_triage'],
        id,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Historial
  Future<void> delete(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query('DELETE FROM Historial WHERE id_historial = ?', [id]);
    await DatabaseHelper.closeConnection(conn);
  }
}
