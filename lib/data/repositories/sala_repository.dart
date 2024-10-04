// Repositorio para la tabla Sala
// repositories/sala_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class SalaRepository {
  // Obtener todos los registros de la tabla Sala
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM Sala');

    List<Map<String, dynamic>> salas = [];
    for (var row in results) {
      salas.add({
        'numero_sala': row['numero_sala'],
        'horario': row['horario'],
        'nombre': row['nombre'],
        'lleno': row['lleno'],
        'id_servicio': row['id_servicio'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return salas;
  }

  // Obtener un registro por ID de la tabla Sala
  Future<Map<String, dynamic>?> getById(int numeroSala) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn
        .query('SELECT * FROM Sala WHERE numero_sala = ?', [numeroSala]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'numero_sala': row['numero_sala'],
        'horario': row['horario'],
        'nombre': row['nombre'],
        'lleno': row['lleno'],
        'id_servicio': row['id_servicio'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Sala
  Future<void> insert(Map<String, dynamic> sala) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO Sala (horario, nombre, lleno, id_servicio) VALUES (?, ?, ?, ?)',
      [
        sala['horario'],
        sala['nombre'],
        sala['lleno'],
        sala['id_servicio'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Sala
  Future<void> update(int numeroSala, Map<String, dynamic> sala) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE Sala SET horario = ?, nombre = ?, lleno = ?, id_servicio = ? WHERE numero_sala = ?',
      [
        sala['horario'],
        sala['nombre'],
        sala['lleno'],
        sala['id_servicio'],
        numeroSala,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Sala
  Future<void> delete(int numeroSala) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query('DELETE FROM Sala WHERE numero_sala = ?', [numeroSala]);
    await DatabaseHelper.closeConnection(conn);
  }
}
