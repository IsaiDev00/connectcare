// Repositorio para la tabla Administrador
// repositories/administrador_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class AdministradorRepository {
  // Obtener todos los registros de la tabla Administrador
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM administrador');

    List<Map<String, dynamic>> administradores = [];
    for (var row in results) {
      administradores.add({
        'id_administrador': row['id_administrador'],
        'horario': row['horario'],
        'clues': row['clues'],
        'id_personal': row['id_personal'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return administradores;
  }

  // Obtener un registro por ID de la tabla Administrador
  Future<Map<String, dynamic>?> getById(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn
        .query('SELECT * FROM administrador WHERE id_administrador = ?', [id]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_administrador': row['id_administrador'],
        'horario': row['horario'],
        'clues': row['clues'],
        'id_personal': row['id_personal'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Administrador
  Future<void> insert(Map<String, dynamic> administrador) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO administrador (horario, clues, id_personal) VALUES (?, ?, ?)',
      [
        administrador['horario'],
        administrador['clues'],
        administrador['id_personal'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Administrador
  Future<void> update(int id, Map<String, dynamic> administrador) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE administrador SET horario = ?, clues = ?, id_personal = ? WHERE id_administrador = ?',
      [
        administrador['horario'],
        administrador['clues'],
        administrador['id_personal'],
        id,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Administrador
  Future<void> delete(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn
        .query('DELETE FROM administrador WHERE id_administrador = ?', [id]);
    await DatabaseHelper.closeConnection(conn);
  }
}
