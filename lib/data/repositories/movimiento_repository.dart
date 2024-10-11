// Repositorio para la tabla Movimiento
// repositories/movimiento_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class MovimientoRepository {
  // Obtener todos los registros de la tabla Movimiento
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM movimiento');

    List<Map<String, dynamic>> movimientos = [];
    for (var row in results) {
      movimientos.add({
        'id_movimiento': row['id_movimiento'],
        'fecha': row['fecha'],
        'hora': row['hora'],
        'tipo': row['tipo'],
        'descripcion': row['descripcion'],
        'id_personal': row['id_personal'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return movimientos;
  }

  // Obtener un registro por ID de la tabla Movimiento
  Future<Map<String, dynamic>?> getById(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn
        .query('SELECT * FROM movimiento WHERE id_movimiento = ?', [id]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_movimiento': row['id_movimiento'],
        'fecha': row['fecha'],
        'hora': row['hora'],
        'tipo': row['tipo'],
        'descripcion': row['descripcion'],
        'id_personal': row['id_personal'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Movimiento
  Future<void> insert(Map<String, dynamic> movimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO movimiento (fecha, hora, tipo, descripcion, id_personal) VALUES (?, ?, ?, ?, ?)',
      [
        movimiento['fecha'],
        movimiento['hora'],
        movimiento['tipo'],
        movimiento['descripcion'],
        movimiento['id_personal'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Movimiento
  Future<void> update(int id, Map<String, dynamic> movimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE movimiento SET fecha = ?, hora = ?, tipo = ?, descripcion = ?, id_personal = ? WHERE id_movimiento = ?',
      [
        movimiento['fecha'],
        movimiento['hora'],
        movimiento['tipo'],
        movimiento['descripcion'],
        movimiento['id_personal'],
        id,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Movimiento
  Future<void> delete(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query('DELETE FROM movimiento WHERE id_movimiento = ?', [id]);
    await DatabaseHelper.closeConnection(conn);
  }
}
