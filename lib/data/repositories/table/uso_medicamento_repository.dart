// Repositorio para la tabla Uso_Medicamento
// repositories/uso_medicamento_repository.dart
import 'package:mysql1/mysql1.dart';
import '../../providers/database_helper.dart';

class UsoMedicamentoRepository {
  // Obtener todos los registros de la tabla Uso_Medicamento
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM uso_medicamento');

    List<Map<String, dynamic>> usosMedicamento = [];
    for (var row in results) {
      usosMedicamento.add({
        'id_uso_medicamento': row['id_uso_medicamento'],
        'cantidad': row['cantidad'],
        'id_medicamento': row['id_medicamento'],
        'id_hoja_de_enfermeria': row['id_hoja_de_enfermeria'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return usosMedicamento;
  }

  // Obtener un registro por ID de la tabla Uso_Medicamento
  Future<Map<String, dynamic>?> getById(int idUsoMedicamento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query(
        'SELECT * FROM uso_medicamento WHERE id_uso_medicamento = ?',
        [idUsoMedicamento]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_uso_medicamento': row['id_uso_medicamento'],
        'cantidad': row['cantidad'],
        'id_medicamento': row['id_medicamento'],
        'id_hoja_de_enfermeria': row['id_hoja_de_enfermeria'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Uso_Medicamento
  Future<void> insert(Map<String, dynamic> usoMedicamento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO uso_medicamento (cantidad, id_medicamento, id_hoja_de_enfermeria) VALUES (?, ?, ?)',
      [
        usoMedicamento['cantidad'],
        usoMedicamento['id_medicamento'],
        usoMedicamento['id_hoja_de_enfermeria'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Uso_Medicamento
  Future<void> update(
      int idUsoMedicamento, Map<String, dynamic> usoMedicamento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE uso_medicamento SET cantidad = ?, id_medicamento = ?, id_hoja_de_enfermeria = ? WHERE id_uso_medicamento = ?',
      [
        usoMedicamento['cantidad'],
        usoMedicamento['id_medicamento'],
        usoMedicamento['id_hoja_de_enfermeria'],
        idUsoMedicamento,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Uso_Medicamento
  Future<void> delete(int idUsoMedicamento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query('DELETE FROM uso_medicamento WHERE id_uso_medicamento = ?',
        [idUsoMedicamento]);
    await DatabaseHelper.closeConnection(conn);
  }
}
