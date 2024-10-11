// Repositorio para la tabla Piso
// repositories/piso_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class PisoRepository {
  // Obtener todos los registros de la tabla Piso
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM piso');

    List<Map<String, dynamic>> pisos = [];
    for (var row in results) {
      pisos.add({
        'numero_piso': row['numero_piso'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return pisos;
  }

  // Obtener un registro por ID de la tabla Piso
  Future<Map<String, dynamic>?> getById(int numeroPiso) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn
        .query('SELECT * FROM piso WHERE numero_piso = ?', [numeroPiso]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'numero_piso': row['numero_piso'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Piso
  Future<void> insert(Map<String, dynamic> piso) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO piso (numero_piso) VALUES (?)',
      [
        piso['numero_piso'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Piso
  Future<void> update(int numeroPiso, Map<String, dynamic> piso) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE piso SET numero_piso = ? WHERE numero_piso = ?',
      [
        piso['numero_piso'],
        numeroPiso,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Piso
  Future<void> delete(int numeroPiso) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query('DELETE FROM piso WHERE numero_piso = ?', [numeroPiso]);
    await DatabaseHelper.closeConnection(conn);
  }
}
