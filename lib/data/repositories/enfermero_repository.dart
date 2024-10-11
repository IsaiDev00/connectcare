// Repositorio para la tabla Enfermero
// repositories/enfermero_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class EnfermeroRepository {
  // Obtener todos los registros de la tabla Enfermero
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM enfermero');

    List<Map<String, dynamic>> enfermeros = [];
    for (var row in results) {
      enfermeros.add({
        'id_enfermero': row['id_enfermero'],
        'horario': row['horario'],
        'jerarquia': row['jerarquia'],
        'id_servicio': row['id_servicio'],
        'id_personal': row['id_personal'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return enfermeros;
  }

  // Obtener un registro por ID de la tabla Enfermero
  Future<Map<String, dynamic>?> getById(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn
        .query('SELECT * FROM enfermero WHERE id_enfermero = ?', [id]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_enfermero': row['id_enfermero'],
        'horario': row['horario'],
        'jerarquia': row['jerarquia'],
        'id_servicio': row['id_servicio'],
        'id_personal': row['id_personal'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Enfermero
  Future<void> insert(Map<String, dynamic> enfermero) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO enfermero (horario, jerarquia, id_servicio, id_personal) VALUES (?, ?, ?, ?)',
      [
        enfermero['horario'],
        enfermero['jerarquia'],
        enfermero['id_servicio'],
        enfermero['id_personal'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Enfermero
  Future<void> update(int id, Map<String, dynamic> enfermero) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE enfermero SET horario = ?, jerarquia = ?, id_servicio = ?, id_personal = ? WHERE id_enfermero = ?',
      [
        enfermero['horario'],
        enfermero['jerarquia'],
        enfermero['id_servicio'],
        enfermero['id_personal'],
        id,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Enfermero
  Future<void> delete(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query('DELETE FROM enfermero WHERE id_enfermero = ?', [id]);
    await DatabaseHelper.closeConnection(conn);
  }
}
