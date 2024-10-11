// Repositorio para la tabla Servicio
// repositories/servicio_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class ServicioRepository {
  // Obtener todos los registros de la tabla Servicio
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM servicio');

    List<Map<String, dynamic>> servicios = [];
    for (var row in results) {
      servicios.add({
        'id_servicio': row['id_servicio'],
        'nombre': row['nombre'],
        'numero_piso': row['numero_piso'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return servicios;
  }

  // Obtener un registro por ID de la tabla Servicio
  Future<Map<String, dynamic>?> getById(int idServicio) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn
        .query('SELECT * FROM servicio WHERE id_servicio = ?', [idServicio]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_servicio': row['id_servicio'],
        'nombre': row['nombre'],
        'numero_piso': row['numero_piso'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Servicio
  Future<void> insert(Map<String, dynamic> servicio) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO servicio (nombre, numero_piso) VALUES (?, ?)',
      [
        servicio['nombre'],
        servicio['numero_piso'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Servicio
  Future<void> update(int idServicio, Map<String, dynamic> servicio) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE servicio SET nombre = ?, numero_piso = ? WHERE id_servicio = ?',
      [
        servicio['nombre'],
        servicio['numero_piso'],
        idServicio,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Servicio
  Future<void> delete(int idServicio) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn
        .query('DELETE FROM servicio WHERE id_servicio = ?', [idServicio]);
    await DatabaseHelper.closeConnection(conn);
  }
}
