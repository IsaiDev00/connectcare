// Repositorio para la tabla Padecimiento
// repositories/padecimiento_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class PadecimientoRepository {
  // Obtener todos los registros de la tabla Padecimiento
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM padecimiento');

    List<Map<String, dynamic>> padecimientos = [];
    for (var row in results) {
      padecimientos.add({
        'id_padecimiento': row['id_padecimiento'],
        'nombre': row['nombre'],
        'gravedad': row['gravedad'],
        'periodo_reposo': row['periodo_reposo'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return padecimientos;
  }

  // Obtener un registro por ID de la tabla Padecimiento
  Future<Map<String, dynamic>?> getById(int idPadecimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query(
        'SELECT * FROM padecimiento WHERE id_padecimiento = ?',
        [idPadecimiento]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_padecimiento': row['id_padecimiento'],
        'nombre': row['nombre'],
        'gravedad': row['gravedad'],
        'periodo_reposo': row['periodo_reposo'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Padecimiento
  Future<void> insert(Map<String, dynamic> padecimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO padecimiento (nombre, gravedad, periodo_reposo) VALUES (?, ?, ?)',
      [
        padecimiento['nombre'],
        padecimiento['gravedad'],
        padecimiento['periodo_reposo'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Padecimiento
  Future<void> update(
      int idPadecimiento, Map<String, dynamic> padecimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE padecimiento SET nombre = ?, gravedad = ?, periodo_reposo = ? WHERE id_padecimiento = ?',
      [
        padecimiento['nombre'],
        padecimiento['gravedad'],
        padecimiento['periodo_reposo'],
        idPadecimiento,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Padecimiento
  Future<void> delete(int idPadecimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
        'DELETE FROM padecimiento WHERE id_padecimiento = ?', [idPadecimiento]);
    await DatabaseHelper.closeConnection(conn);
  }
}
