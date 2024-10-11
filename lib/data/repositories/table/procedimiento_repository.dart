// Repositorio para la tabla Procedimiento
// repositories/procedimiento_repository.dart
import 'package:mysql1/mysql1.dart';
import '../../providers/database_helper.dart';

class ProcedimientoRepository {
  // Obtener todos los registros de la tabla Procedimiento
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM procedimiento');

    List<Map<String, dynamic>> procedimientos = [];
    for (var row in results) {
      procedimientos.add({
        'id_procedimiento': row['id_procedimiento'],
        'nombre': row['nombre'],
        'descripcion': row['descripcion'],
        'cantidad_enfermeros': row['cantidad_enfermeros'],
        'cantidad_medicos': row['cantidad_medicos'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return procedimientos;
  }

  // Obtener un registro por ID de la tabla Procedimiento
  Future<Map<String, dynamic>?> getById(int idProcedimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query(
        'SELECT * FROM procedimiento WHERE id_procedimiento = ?',
        [idProcedimiento]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_procedimiento': row['id_procedimiento'],
        'nombre': row['nombre'],
        'descripcion': row['descripcion'],
        'cantidad_enfermeros': row['cantidad_enfermeros'],
        'cantidad_medicos': row['cantidad_medicos'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Procedimiento
  Future<void> insert(Map<String, dynamic> procedimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO procedimiento (nombre, descripcion, cantidad_enfermeros, cantidad_medicos) VALUES (?, ?, ?, ?)',
      [
        procedimiento['nombre'],
        procedimiento['descripcion'],
        procedimiento['cantidad_enfermeros'],
        procedimiento['cantidad_medicos'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Procedimiento
  Future<void> update(
      int idProcedimiento, Map<String, dynamic> procedimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE procedimiento SET nombre = ?, descripcion = ?, cantidad_enfermeros = ?, cantidad_medicos = ? WHERE id_procedimiento = ?',
      [
        procedimiento['nombre'],
        procedimiento['descripcion'],
        procedimiento['cantidad_enfermeros'],
        procedimiento['cantidad_medicos'],
        idProcedimiento,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Procedimiento
  Future<void> delete(int idProcedimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query('DELETE FROM procedimiento WHERE id_procedimiento = ?',
        [idProcedimiento]);
    await DatabaseHelper.closeConnection(conn);
  }
}
