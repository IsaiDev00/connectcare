// Repositorio para la tabla Medicamento
// repositories/medicamento_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class MedicamentoRepository {
  // Obtener todos los registros de la tabla Medicamento
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM Medicamento');

    List<Map<String, dynamic>> medicamentos = [];
    for (var row in results) {
      medicamentos.add({
        'id_medicamento': row['id_medicamento'],
        'nombre': row['nombre'],
        'marca': row['marca'],
        'tipo': row['tipo'],
        'cantidad_presentacion': row['cantidad_presentacion'],
        'concentracion': row['concentracion'],
        'cantidad_stock': row['cantidad_stock'],
        'caducidad': row['caducidad'],
        'id_administrador': row['id_administrador'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return medicamentos;
  }

  // Obtener un registro por ID de la tabla Medicamento
  Future<Map<String, dynamic>?> getById(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn
        .query('SELECT * FROM Medicamento WHERE id_medicamento = ?', [id]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_medicamento': row['id_medicamento'],
        'nombre': row['nombre'],
        'marca': row['marca'],
        'tipo': row['tipo'],
        'cantidad_presentacion': row['cantidad_presentacion'],
        'concentracion': row['concentracion'],
        'cantidad_stock': row['cantidad_stock'],
        'caducidad': row['caducidad'],
        'id_administrador': row['id_administrador'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Medicamento
  Future<void> insert(Map<String, dynamic> medicamento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO Medicamento (nombre, marca, tipo, cantidad_presentacion, concentracion, cantidad_stock, caducidad, id_administrador) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        medicamento['nombre'],
        medicamento['marca'],
        medicamento['tipo'],
        medicamento['cantidad_presentacion'],
        medicamento['concentracion'],
        medicamento['cantidad_stock'],
        medicamento['caducidad'],
        medicamento['id_administrador'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Medicamento
  Future<void> update(int id, Map<String, dynamic> medicamento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE Medicamento SET nombre = ?, marca = ?, tipo = ?, cantidad_presentacion = ?, concentracion = ?, cantidad_stock = ?, caducidad = ?, id_administrador = ? WHERE id_medicamento = ?',
      [
        medicamento['nombre'],
        medicamento['marca'],
        medicamento['tipo'],
        medicamento['cantidad_presentacion'],
        medicamento['concentracion'],
        medicamento['cantidad_stock'],
        medicamento['caducidad'],
        medicamento['id_administrador'],
        id,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Medicamento
  Future<void> delete(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query('DELETE FROM Medicamento WHERE id_medicamento = ?', [id]);
    await DatabaseHelper.closeConnection(conn);
  }
}
