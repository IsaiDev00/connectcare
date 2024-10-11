// Repositorio para la tabla Cama
// repositories/cama_repository.dart
import 'package:mysql1/mysql1.dart';
import '../../providers/database_helper.dart';

class CamaRepository {
  // Obtener todos los registros de la tabla Cama
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM cama');

    List<Map<String, dynamic>> camas = [];
    for (var row in results) {
      camas.add({
        'numero_cama': row['numero_cama'],
        'tipo': row['tipo'],
        'en_uso': row['en_uso'],
        'numero_sala': row['numero_sala'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return camas;
  }

  // Obtener un registro por ID de la tabla Cama
  Future<Map<String, dynamic>?> getById(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results =
        await conn.query('SELECT * FROM cama WHERE numero_cama = ?', [id]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'numero_cama': row['numero_cama'],
        'tipo': row['tipo'],
        'en_uso': row['en_uso'],
        'numero_sala': row['numero_sala'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Cama
  Future<void> insert(Map<String, dynamic> cama) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO cama (tipo, en_uso, numero_sala) VALUES (?, ?, ?)',
      [
        cama['tipo'],
        cama['en_uso'],
        cama['numero_sala'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Cama
  Future<void> update(int id, Map<String, dynamic> cama) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE cama SET tipo = ?, en_uso = ?, numero_sala = ? WHERE numero_cama = ?',
      [
        cama['tipo'],
        cama['en_uso'],
        cama['numero_sala'],
        id,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Cama
  Future<void> delete(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query('DELETE FROM cama WHERE numero_cama = ?', [id]);
    await DatabaseHelper.closeConnection(conn);
  }
}
