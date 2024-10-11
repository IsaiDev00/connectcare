// Repositorio para la tabla Traslado
// repositories/traslado_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class TrasladoRepository {
  // Obtener todos los registros de la tabla Traslado
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM traslado');

    List<Map<String, dynamic>> traslados = [];
    for (var row in results) {
      traslados.add({
        'id_traslado': row['id_traslado'],
        'fecha': row['fecha'],
        'hora': row['hora'],
        'nss_paciente': row['nss_paciente'],
        'numero_cama': row['numero_cama'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return traslados;
  }

  // Obtener un registro por ID de la tabla Traslado
  Future<Map<String, dynamic>?> getById(int idTraslado) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn
        .query('SELECT * FROM traslado WHERE id_traslado = ?', [idTraslado]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_traslado': row['id_traslado'],
        'fecha': row['fecha'],
        'hora': row['hora'],
        'nss_paciente': row['nss_paciente'],
        'numero_cama': row['numero_cama'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Traslado
  Future<void> insert(Map<String, dynamic> traslado) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO traslado (fecha, hora, nss_paciente, numero_cama) VALUES (?, ?, ?, ?)',
      [
        traslado['fecha'],
        traslado['hora'],
        traslado['nss_paciente'],
        traslado['numero_cama'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Traslado
  Future<void> update(int idTraslado, Map<String, dynamic> traslado) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE traslado SET fecha = ?, hora = ?, nss_paciente = ?, numero_cama = ? WHERE id_traslado = ?',
      [
        traslado['fecha'],
        traslado['hora'],
        traslado['nss_paciente'],
        traslado['numero_cama'],
        idTraslado,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Traslado
  Future<void> delete(int idTraslado) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn
        .query('DELETE FROM traslado WHERE id_traslado = ?', [idTraslado]);
    await DatabaseHelper.closeConnection(conn);
  }
}
