// Repositorio para la tabla Horario_Visita
// repositories/horario_visita_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class HorarioVisitaRepository {
  // Obtener todos los registros de la tabla Horario_Visita
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM Horario_Visita');

    List<Map<String, dynamic>> horariosVisita = [];
    for (var row in results) {
      horariosVisita.add({
        'id_horario_visita': row['id_horario_visita'],
        'inicio': row['inicio'],
        'fin': row['fin'],
        'visitantes': row['visitantes'],
        'id_sala': row['id_sala'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return horariosVisita;
  }

  // Obtener un registro por ID de la tabla Horario_Visita
  Future<Map<String, dynamic>?> getById(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query(
        'SELECT * FROM Horario_Visita WHERE id_horario_visita = ?', [id]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_horario_visita': row['id_horario_visita'],
        'inicio': row['inicio'],
        'fin': row['fin'],
        'visitantes': row['visitantes'],
        'id_sala': row['id_sala'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Horario_Visita
  Future<void> insert(Map<String, dynamic> horarioVisita) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO Horario_Visita (inicio, fin, visitantes, id_sala) VALUES (?, ?, ?, ?)',
      [
        horarioVisita['inicio'],
        horarioVisita['fin'],
        horarioVisita['visitantes'],
        horarioVisita['id_sala'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Horario_Visita
  Future<void> update(int id, Map<String, dynamic> horarioVisita) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE Horario_Visita SET inicio = ?, fin = ?, visitantes = ?, id_sala = ? WHERE id_horario_visita = ?',
      [
        horarioVisita['inicio'],
        horarioVisita['fin'],
        horarioVisita['visitantes'],
        horarioVisita['id_sala'],
        id,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Horario_Visita
  Future<void> delete(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn
        .query('DELETE FROM Horario_Visita WHERE id_horario_visita = ?', [id]);
    await DatabaseHelper.closeConnection(conn);
  }
}
