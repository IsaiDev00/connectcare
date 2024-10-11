// Repositorio para la tabla RH
// repositories/rh_repository.dart
import 'package:mysql1/mysql1.dart';
import '../../providers/database_helper.dart';

class RHRepository {
  // Obtener todos los registros de la tabla RH
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM rh');

    List<Map<String, dynamic>> rhRecords = [];
    for (var row in results) {
      rhRecords.add({
        'id_rh': row['id_rh'],
        'horario': row['horario'],
        'id_personal': row['id_personal'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return rhRecords;
  }

  // Obtener un registro por ID de la tabla RH
  Future<Map<String, dynamic>?> getById(int idRH) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM rh WHERE id_rh = ?', [idRH]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_rh': row['id_rh'],
        'horario': row['horario'],
        'id_personal': row['id_personal'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla RH
  Future<void> insert(Map<String, dynamic> rhRecord) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO rh (horario, id_personal) VALUES (?, ?)',
      [
        rhRecord['horario'],
        rhRecord['id_personal'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla RH
  Future<void> update(int idRH, Map<String, dynamic> rhRecord) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE rh SET horario = ?, id_personal = ? WHERE id_rh = ?',
      [
        rhRecord['horario'],
        rhRecord['id_personal'],
        idRH,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla RH
  Future<void> delete(int idRH) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query('DELETE FROM rh WHERE id_rh = ?', [idRH]);
    await DatabaseHelper.closeConnection(conn);
  }
}
