// Repositorio para la tabla Trabajo_Social
// repositories/trabajo_social_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class TrabajoSocialRepository {
  // Obtener todos los registros de la tabla Trabajo_Social
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM trabajo_social');

    List<Map<String, dynamic>> trabajosSociales = [];
    for (var row in results) {
      trabajosSociales.add({
        'id_trabajo_social': row['id_trabajo_social'],
        'horario': row['horario'],
        'id_personal': row['id_personal'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return trabajosSociales;
  }

  // Obtener un registro por ID de la tabla Trabajo_Social
  Future<Map<String, dynamic>?> getById(int idTrabajoSocial) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query(
        'SELECT * FROM trabajo_social WHERE id_trabajo_social = ?',
        [idTrabajoSocial]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_trabajo_social': row['id_trabajo_social'],
        'horario': row['horario'],
        'id_personal': row['id_personal'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Trabajo_Social
  Future<void> insert(Map<String, dynamic> trabajoSocial) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO trabajo_social (horario, id_personal) VALUES (?, ?)',
      [
        trabajoSocial['horario'],
        trabajoSocial['id_personal'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Trabajo_Social
  Future<void> update(
      int idTrabajoSocial, Map<String, dynamic> trabajoSocial) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE trabajo_social SET horario = ?, id_personal = ? WHERE id_trabajo_social = ?',
      [
        trabajoSocial['horario'],
        trabajoSocial['id_personal'],
        idTrabajoSocial,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Trabajo_Social
  Future<void> delete(int idTrabajoSocial) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query('DELETE FROM trabajo_social WHERE id_trabajo_social = ?',
        [idTrabajoSocial]);
    await DatabaseHelper.closeConnection(conn);
  }
}
