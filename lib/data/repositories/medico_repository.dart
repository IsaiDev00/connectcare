// Repositorio para la tabla Medico
// repositories/medico_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class MedicoRepository {
  // Obtener todos los registros de la tabla Medico
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM medico');

    List<Map<String, dynamic>> medicos = [];
    for (var row in results) {
      medicos.add({
        'id_medico': row['id_medico'],
        'especialidad': row['especialidad'],
        'jerarquia': row['jerarquia'],
        'horario': row['horario'],
        'id_servicio': row['id_servicio'],
        'id_personal': row['id_personal'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return medicos;
  }

  // Obtener un registro por ID de la tabla Medico
  Future<Map<String, dynamic>?> getById(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results =
        await conn.query('SELECT * FROM medico WHERE id_medico = ?', [id]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_medico': row['id_medico'],
        'especialidad': row['especialidad'],
        'jerarquia': row['jerarquia'],
        'horario': row['horario'],
        'id_servicio': row['id_servicio'],
        'id_personal': row['id_personal'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Medico
  Future<void> insert(Map<String, dynamic> medico) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO medico (especialidad, jerarquia, horario, id_servicio, id_personal) VALUES (?, ?, ?, ?, ?)',
      [
        medico['especialidad'],
        medico['jerarquia'],
        medico['horario'],
        medico['id_servicio'],
        medico['id_personal'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Medico
  Future<void> update(int id, Map<String, dynamic> medico) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE medico SET especialidad = ?, jerarquia = ?, horario = ?, id_servicio = ?, id_personal = ? WHERE id_medico = ?',
      [
        medico['especialidad'],
        medico['jerarquia'],
        medico['horario'],
        medico['id_servicio'],
        medico['id_personal'],
        id,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Medico
  Future<void> delete(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query('DELETE FROM medico WHERE id_medico = ?', [id]);
    await DatabaseHelper.closeConnection(conn);
  }
}
