// Repositorio para la tabla Personal_No_Asignado
// repositories/personal_no_asignado_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class PersonalNoAsignadoRepository {
  // Obtener todos los registros de la tabla Personal_No_Asignado
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM Personal_No_Asignado');

    List<Map<String, dynamic>> personalNoAsignado = [];
    for (var row in results) {
      personalNoAsignado.add({
        'id_personal_no_asignado': row['id_personal_no_asignado'],
        'nombre': row['nombre'],
        'apellido_paterno': row['apellido_paterno'],
        'apellido_materno': row['apellido_materno'],
        'correo_electronico': row['correo_electronico'],
        'tipo': row['tipo'],
        'telefono': row['telefono'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return personalNoAsignado;
  }

  // Obtener un registro por ID de la tabla Personal_No_Asignado
  Future<Map<String, dynamic>?> getById(int idPersonalNoAsignado) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query(
        'SELECT * FROM Personal_No_Asignado WHERE id_personal_no_asignado = ?',
        [idPersonalNoAsignado]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_personal_no_asignado': row['id_personal_no_asignado'],
        'nombre': row['nombre'],
        'apellido_paterno': row['apellido_paterno'],
        'apellido_materno': row['apellido_materno'],
        'correo_electronico': row['correo_electronico'],
        'tipo': row['tipo'],
        'telefono': row['telefono'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Personal_No_Asignado
  Future<void> insert(Map<String, dynamic> personalNoAsignado) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO Personal_No_Asignado (nombre, apellido_paterno, apellido_materno, correo_electronico, tipo, telefono) VALUES (?, ?, ?, ?, ?, ?)',
      [
        personalNoAsignado['nombre'],
        personalNoAsignado['apellido_paterno'],
        personalNoAsignado['apellido_materno'],
        personalNoAsignado['correo_electronico'],
        personalNoAsignado['tipo'],
        personalNoAsignado['telefono'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Personal_No_Asignado
  Future<void> update(
      int idPersonalNoAsignado, Map<String, dynamic> personalNoAsignado) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE Personal_No_Asignado SET nombre = ?, apellido_paterno = ?, apellido_materno = ?, correo_electronico = ?, tipo = ?, telefono = ? WHERE id_personal_no_asignado = ?',
      [
        personalNoAsignado['nombre'],
        personalNoAsignado['apellido_paterno'],
        personalNoAsignado['apellido_materno'],
        personalNoAsignado['correo_electronico'],
        personalNoAsignado['tipo'],
        personalNoAsignado['telefono'],
        idPersonalNoAsignado,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Personal_No_Asignado
  Future<void> delete(int idPersonalNoAsignado) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
        'DELETE FROM Personal_No_Asignado WHERE id_personal_no_asignado = ?',
        [idPersonalNoAsignado]);
    await DatabaseHelper.closeConnection(conn);
  }
}
