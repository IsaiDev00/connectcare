// Repositorio para la tabla Sala_Procedimiento
// repositories/sala_procedimiento_repository.dart
import 'package:mysql1/mysql1.dart';
import '../../providers/database_helper.dart';

class SalaProcedimientoRepository {
  // Obtener todos los registros de la tabla Sala_Procedimiento
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM sala_procedimiento');

    List<Map<String, dynamic>> salaProcedimientos = [];
    for (var row in results) {
      salaProcedimientos.add({
        'numero_sala': row['numero_sala'],
        'id_procedimiento': row['id_procedimiento'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return salaProcedimientos;
  }

  // Obtener un registro por ID de la tabla Sala_Procedimiento
  Future<Map<String, dynamic>?> getById(
      int numeroSala, int idProcedimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query(
      'SELECT * FROM sala_procedimiento WHERE numero_sala = ? AND id_procedimiento = ?',
      [numeroSala, idProcedimiento],
    );

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'numero_sala': row['numero_sala'],
        'id_procedimiento': row['id_procedimiento'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Sala_Procedimiento
  Future<void> insert(Map<String, dynamic> salaProcedimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO sala_procedimiento (numero_sala, id_procedimiento) VALUES (?, ?)',
      [
        salaProcedimiento['numero_sala'],
        salaProcedimiento['id_procedimiento'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Sala_Procedimiento
  Future<void> update(int numeroSala, int idProcedimiento,
      Map<String, dynamic> salaProcedimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE sala_procedimiento SET numero_sala = ?, id_procedimiento = ? WHERE numero_sala = ? AND id_procedimiento = ?',
      [
        salaProcedimiento['numero_sala'],
        salaProcedimiento['id_procedimiento'],
        numeroSala,
        idProcedimiento,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Sala_Procedimiento
  Future<void> delete(int numeroSala, int idProcedimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'DELETE FROM sala_procedimiento WHERE numero_sala = ? AND id_procedimiento = ?',
      [numeroSala, idProcedimiento],
    );
    await DatabaseHelper.closeConnection(conn);
  }
}
