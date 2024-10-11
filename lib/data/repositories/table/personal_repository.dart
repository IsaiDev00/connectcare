// Repositorio para la tabla Personal
// repositories/personal_repository.dart
import 'package:mysql1/mysql1.dart';
import '../../providers/database_helper.dart';

class PersonalRepository {
  // Obtener todos los registros de la tabla Personal
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM personal');

    List<Map<String, dynamic>> personal = [];
    for (var row in results) {
      personal.add({
        'id_personal': row['id_personal'],
        'nombre': row['nombre'],
        'apellido_paterno': row['apellido_paterno'],
        'apellido_materno': row['apellido_materno'],
        'tipo': row['tipo'],
        'correo_electronico': row['correo_electronico'],
        'contrasena': row['contrasena'],
        'telefono': row['telefono'],
        'estatus': row['estatus'],
        'asignado': row['asignado'],
        'clues': row['clues'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return personal;
  }

  // Obtener un registro por ID de la tabla Personal
  Future<Map<String, dynamic>?> getById(int idPersonal) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn
        .query('SELECT * FROM personal WHERE id_personal = ?', [idPersonal]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_personal': row['id_personal'],
        'nombre': row['nombre'],
        'apellido_paterno': row['apellido_paterno'],
        'apellido_materno': row['apellido_materno'],
        'tipo': row['tipo'],
        'correo_electronico': row['correo_electronico'],
        'contrasena': row['contrasena'],
        'telefono': row['telefono'],
        'estatus': row['estatus'],
        'asignado': row['asignado'],
        'clues': row['clues'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Personal
  Future<void> insert(Map<String, dynamic> personal) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO personal (nombre, apellido_paterno, apellido_materno, tipo, correo_electronico, contrasena, telefono, estatus, clues) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        personal['nombre'],
        personal['apellido_paterno'],
        personal['apellido_materno'],
        personal['tipo'],
        personal['correo_electronico'],
        personal['contrasena'],
        personal['telefono'],
        personal['estatus'],
        personal['asignado'],
        personal['clues'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Personal
  Future<void> update(int idPersonal, Map<String, dynamic> personal) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE personal SET nombre = ?, apellido_paterno = ?, apellido_materno = ?, tipo = ?, correo_electronico = ?, contrasena = ?, telefono = ?, estatus = ?, clues = ? WHERE id_personal = ?',
      [
        personal['nombre'],
        personal['apellido_paterno'],
        personal['apellido_materno'],
        personal['tipo'],
        personal['correo_electronico'],
        personal['contrasena'],
        personal['telefono'],
        personal['estatus'],
        personal['asignado'],
        personal['clues'],
        idPersonal,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Personal
  Future<void> delete(int idPersonal) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn
        .query('DELETE FROM personal WHERE id_personal = ?', [idPersonal]);
    await DatabaseHelper.closeConnection(conn);
  }
}
