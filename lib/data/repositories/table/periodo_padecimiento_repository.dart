// Repositorio para la tabla Periodo_Padecimiento
// repositories/periodo_padecimiento_repository.dart
import 'package:mysql1/mysql1.dart';
import '../../providers/database_helper.dart';

class PeriodoPadecimientoRepository {
  // Obtener todos los registros de la tabla Periodo_Padecimiento
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM periodo_padecimiento');

    List<Map<String, dynamic>> periodosPadecimiento = [];
    for (var row in results) {
      periodosPadecimiento.add({
        'id_periodo_padecimiento': row['id_periodo_padecimiento'],
        'periodo_reposo': row['periodo_reposo'],
        'edad': row['edad'],
        'gravedad': row['gravedad'],
        'f_inicio': row['f_inicio'],
        'f_fin': row['f_fin'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return periodosPadecimiento;
  }

  // Obtener un registro por ID de la tabla Periodo_Padecimiento
  Future<Map<String, dynamic>?> getById(int idPeriodoPadecimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query(
        'SELECT * FROM periodo_padecimiento WHERE id_periodo_padecimiento = ?',
        [idPeriodoPadecimiento]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_periodo_padecimiento': row['id_periodo_padecimiento'],
        'periodo_reposo': row['periodo_reposo'],
        'edad': row['edad'],
        'gravedad': row['gravedad'],
        'f_inicio': row['f_inicio'],
        'f_fin': row['f_fin'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Periodo_Padecimiento
  Future<void> insert(Map<String, dynamic> periodoPadecimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO periodo_padecimiento (periodo_reposo, edad, gravedad, f_inicio, f_fin) VALUES (?, ?, ?, ?, ?)',
      [
        periodoPadecimiento['periodo_reposo'],
        periodoPadecimiento['edad'],
        periodoPadecimiento['gravedad'],
        periodoPadecimiento['f_inicio'],
        periodoPadecimiento['f_fin'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Periodo_Padecimiento
  Future<void> update(int idPeriodoPadecimiento,
      Map<String, dynamic> periodoPadecimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE periodo_padecimiento SET periodo_reposo = ?, edad = ?, gravedad = ?, f_inicio = ?, f_fin = ? WHERE id_periodo_padecimiento = ?',
      [
        periodoPadecimiento['periodo_reposo'],
        periodoPadecimiento['edad'],
        periodoPadecimiento['gravedad'],
        periodoPadecimiento['f_inicio'],
        periodoPadecimiento['f_fin'],
        idPeriodoPadecimiento,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Periodo_Padecimiento
  Future<void> delete(int idPeriodoPadecimiento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
        'DELETE FROM periodo_padecimiento WHERE id_periodo_padecimiento = ?',
        [idPeriodoPadecimiento]);
    await DatabaseHelper.closeConnection(conn);
  }
}
