// Repositorio para la tabla Medicina_Pers
// repositories/medicina_pers_repository.dart
import 'package:mysql1/mysql1.dart';
import '../../providers/database_helper.dart';

class MedicinaPersRepository {
  // Obtener todos los registros de la tabla Medicina_Pers
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM medicina_pers');

    List<Map<String, dynamic>> medicinasPers = [];
    for (var row in results) {
      medicinasPers.add({
        'id_medicina_pers': row['id_medicina_pers'],
        'id_solicitud_medicamento': row['id_solicitud_medicamento'],
        'concentracion': row['concentracion'],
        'caducidad': row['caducidad'],
        'cantidad_stock': row['cantidad_stock'],
        'tipo': row['tipo'],
        'marca': row['marca'],
        'nombre': row['nombre'],
        'cantidad_presentacion': row['cantidad_presentacion'],
        'nss_paciente': row['nss_paciente'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return medicinasPers;
  }

  // Obtener un registro por ID de la tabla Medicina_Pers
  Future<Map<String, dynamic>?> getById(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn
        .query('SELECT * FROM medicina_pers WHERE id_medicina_pers = ?', [id]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_medicina_pers': row['id_medicina_pers'],
        'id_solicitud_medicamento': row['id_solicitud_medicamento'],
        'concentracion': row['concentracion'],
        'caducidad': row['caducidad'],
        'cantidad_stock': row['cantidad_stock'],
        'tipo': row['tipo'],
        'marca': row['marca'],
        'nombre': row['nombre'],
        'cantidad_presentacion': row['cantidad_presentacion'],
        'nss_paciente': row['nss_paciente'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Medicina_Pers
  Future<void> insert(Map<String, dynamic> medicinaPers) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO medicina_pers (id_solicitud_medicamento, concentracion, caducidad, cantidad_stock, tipo, marca, nombre, cantidad_presentacion, nss_paciente) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        medicinaPers['id_solicitud_medicamento'],
        medicinaPers['concentracion'],
        medicinaPers['caducidad'],
        medicinaPers['cantidad_stock'],
        medicinaPers['tipo'],
        medicinaPers['marca'],
        medicinaPers['nombre'],
        medicinaPers['cantidad_presentacion'],
        medicinaPers['nss_paciente'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Medicina_Pers
  Future<void> update(int id, Map<String, dynamic> medicinaPers) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE medicina_pers SET id_solicitud_medicamento = ?, concentracion = ?, caducidad = ?, cantidad_stock = ?, tipo = ?, marca = ?, nombre = ?, cantidad_presentacion = ?, nss_paciente = ? WHERE id_medicina_pers = ?',
      [
        medicinaPers['id_solicitud_medicamento'],
        medicinaPers['concentracion'],
        medicinaPers['caducidad'],
        medicinaPers['cantidad_stock'],
        medicinaPers['tipo'],
        medicinaPers['marca'],
        medicinaPers['nombre'],
        medicinaPers['cantidad_presentacion'],
        medicinaPers['nss_paciente'],
        id,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Medicina_Pers
  Future<void> delete(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn
        .query('DELETE FROM medicina_pers WHERE id_medicina_pers = ?', [id]);
    await DatabaseHelper.closeConnection(conn);
  }
}
