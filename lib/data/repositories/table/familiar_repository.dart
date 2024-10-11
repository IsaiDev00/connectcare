// Repositorio para la tabla Familiar
// repositories/familiar_repository.dart
import 'package:mysql1/mysql1.dart';
import '../../providers/database_helper.dart';

class FamiliarRepository {
  // Obtener todos los registros de la tabla Familiar
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM familiar');

    List<Map<String, dynamic>> familiares = [];
    for (var row in results) {
      familiares.add({
        'id_familiar': row['id_familiar'],
        'nombre': row['nombre'],
        'apellido_paterno': row['apellido_paterno'],
        'apellido_materno': row['apellido_materno'],
        'correo_electronico': row['correo_electronico'],
        'contrasena': row['contrasena'],
        'telefono': row['telefono'],
        'tipo': row['tipo'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return familiares;
  }

  // Obtener un registro por ID de la tabla Familiar
  Future<Map<String, dynamic>?> getById(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results =
        await conn.query('SELECT * fROM Familiar WHERE id_familiar = ?', [id]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_familiar': row['id_familiar'],
        'nombre': row['nombre'],
        'apellido_paterno': row['apellido_paterno'],
        'apellido_materno': row['apellido_materno'],
        'correo_electronico': row['correo_electronico'],
        'contrasena': row['contrasena'],
        'telefono': row['telefono'],
        'tipo': row['tipo'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Familiar
  Future<void> insert(Map<String, dynamic> familiar) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO familiar (nombre, apellido_paterno, apellido_materno, correo_electronico, contrasena, telefono, tipo) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        familiar['nombre'],
        familiar['apellido_paterno'],
        familiar['apellido_materno'],
        familiar['correo_electronico'],
        familiar['contrasena'],
        familiar['telefono'],
        familiar['tipo'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Familiar
  Future<void> update(int id, Map<String, dynamic> familiar) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE familiar SET nombre = ?, apellido_paterno = ?, apellido_materno = ?, correo_electronico = ?, contrasena = ?, telefono = ?, tipo = ? WHERE id_familiar = ?',
      [
        familiar['nombre'],
        familiar['apellido_paterno'],
        familiar['apellido_materno'],
        familiar['correo_electronico'],
        familiar['contrasena'],
        familiar['telefono'],
        familiar['tipo'],
        id,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Familiar
  Future<void> delete(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query('DELETE FROM familiar WHERE id_familiar = ?', [id]);
    await DatabaseHelper.closeConnection(conn);
  }
}
