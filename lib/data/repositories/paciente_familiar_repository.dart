// Repositorio para la tabla Paciente_Familiar
// repositories/paciente_familiar_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class PacienteFamiliarRepository {
  // Obtener todos los registros de la tabla Paciente_Familiar
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM paciente_familiar');

    List<Map<String, dynamic>> pacientesFamiliares = [];
    for (var row in results) {
      pacientesFamiliares.add({
        'nss_paciente': row['nss_paciente'],
        'id_familiar': row['id_familiar'],
        'fecha': row['fecha'],
        'relacion': row['relacion'],
        'id_trabajo_social': row['id_trabajo_social'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return pacientesFamiliares;
  }

  // Obtener un registro por ID de la tabla Paciente_Familiar
  Future<Map<String, dynamic>?> getById(int nssPaciente, int idFamiliar) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query(
      'SELECT * FROM paciente_familiar WHERE nss_paciente = ? AND id_familiar = ?',
      [nssPaciente, idFamiliar],
    );

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'nss_paciente': row['nss_paciente'],
        'id_familiar': row['id_familiar'],
        'fecha': row['fecha'],
        'relacion': row['relacion'],
        'id_trabajo_social': row['id_trabajo_social'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Paciente_Familiar
  Future<void> insert(Map<String, dynamic> pacienteFamiliar) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO paciente_familiar (nss_paciente, id_familiar, fecha, relacion, id_trabajo_social) VALUES (?, ?, ?, ?, ?)',
      [
        pacienteFamiliar['nss_paciente'],
        pacienteFamiliar['id_familiar'],
        pacienteFamiliar['fecha'],
        pacienteFamiliar['relacion'],
        pacienteFamiliar['id_trabajo_social'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Paciente_Familiar
  Future<void> update(int nssPaciente, int idFamiliar,
      Map<String, dynamic> pacienteFamiliar) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE paciente_familiar SET fecha = ?, relacion = ?, id_trabajo_social = ? WHERE nss_paciente = ? AND id_familiar = ?',
      [
        pacienteFamiliar['fecha'],
        pacienteFamiliar['relacion'],
        pacienteFamiliar['id_trabajo_social'],
        nssPaciente,
        idFamiliar,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Paciente_Familiar
  Future<void> delete(int nssPaciente, int idFamiliar) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'DELETE FROM paciente_familiar WHERE nss_paciente = ? AND id_familiar = ?',
      [nssPaciente, idFamiliar],
    );
    await DatabaseHelper.closeConnection(conn);
  }
}
