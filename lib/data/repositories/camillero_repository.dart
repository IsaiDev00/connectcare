// Repositorio para la tabla Camillero
// repositories/camillero_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class CamilleroRepository {
  // Obtener todos los registros de la tabla Camillero
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM Camillero');

    List<Map<String, dynamic>> camilleros = [];
    for (var row in results) {
      camilleros.add({
        'id_camillero': row['id_camillero'],
        'jerarquia': row['jerarquia'],
        'horario': row['horario'],
        'id_servicio': row['id_servicio'],
        'id_personal': row['id_personal'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return camilleros;
  }

  // Obtener un registro por ID de la tabla Camillero
  Future<Map<String, dynamic>?> getById(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn
        .query('SELECT * FROM Camillero WHERE id_camillero = ?', [id]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_camillero': row['id_camillero'],
        'jerarquia': row['jerarquia'],
        'horario': row['horario'],
        'id_servicio': row['id_servicio'],
        'id_personal': row['id_personal'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Camillero
  Future<void> insert(Map<String, dynamic> camillero) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO Camillero (jerarquia, horario, id_servicio, id_personal) VALUES (?, ?, ?, ?)',
      [
        camillero['jerarquia'],
        camillero['horario'],
        camillero['id_servicio'],
        camillero['id_personal'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Camillero
  Future<void> update(int id, Map<String, dynamic> camillero) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE Camillero SET jerarquia = ?, horario = ?, id_servicio = ?, id_personal = ? WHERE id_camillero = ?',
      [
        camillero['jerarquia'],
        camillero['horario'],
        camillero['id_servicio'],
        camillero['id_personal'],
        id,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Camillero
  Future<void> delete(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query('DELETE FROM Camillero WHERE id_camillero = ?', [id]);
    await DatabaseHelper.closeConnection(conn);
  }
}
