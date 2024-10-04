// Repositorio para la tabla Agenda_Procedimiento
// repositories/agenda_procedimiento_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class AgendaProcedimientoRepository {
  // Obtener todos los registros de la tabla Agenda_Procedimiento
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM Agenda_Procedimiento');

    List<Map<String, dynamic>> agendaProcedimientos = [];
    for (var row in results) {
      agendaProcedimientos.add({
        'id_agenda_procedimiento': row['id_agenda_procedimiento'],
        'fecha': row['fecha'],
        'hora': row['hora'],
        'id_procedimiento': row['id_procedimiento'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return agendaProcedimientos;
  }

  // Obtener un registro por ID de la tabla Agenda_Procedimiento
  Future<Map<String, dynamic>?> getById(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query(
        'SELECT * FROM Agenda_Procedimiento WHERE id_agenda_procedimiento = ?',
        [id]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_agenda_procedimiento': row['id_agenda_procedimiento'],
        'fecha': row['fecha'],
        'hora': row['hora'],
        'id_procedimiento': row['id_procedimiento'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Agenda_Procedimiento
  Future<void> insert(Map<String, dynamic> agendaProcedimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO Agenda_Procedimiento (fecha, hora, id_procedimiento) VALUES (?, ?, ?)',
      [
        agendaProcedimiento['fecha'],
        agendaProcedimiento['hora'],
        agendaProcedimiento['id_procedimiento'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Agenda_Procedimiento
  Future<void> update(int id, Map<String, dynamic> agendaProcedimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE Agenda_Procedimiento SET fecha = ?, hora = ?, id_procedimiento = ? WHERE id_agenda_procedimiento = ?',
      [
        agendaProcedimiento['fecha'],
        agendaProcedimiento['hora'],
        agendaProcedimiento['id_procedimiento'],
        id,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Agenda_Procedimiento
  Future<void> delete(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
        'DELETE FROM Agenda_Procedimiento WHERE id_agenda_procedimiento = ?',
        [id]);
    await DatabaseHelper.closeConnection(conn);
  }
}
