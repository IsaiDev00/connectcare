// Repositorio para la tabla Solicitud_Medicamento
// repositories/solicitud_medicamento_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class SolicitudMedicamentoRepository {
  // Obtener todos los registros de la tabla Solicitud_Medicamento
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM Solicitud_Medicamento');

    List<Map<String, dynamic>> solicitudesMedicamento = [];
    for (var row in results) {
      solicitudesMedicamento.add({
        'id_solicitud_medicamento': row['id_solicitud_medicamento'],
        'concentracion': row['concentracion'],
        'cantidad_presentacion': row['cantidad_presentacion'],
        'nombre': row['nombre'],
        'marca': row['marca'],
        'tipo': row['tipo'],
        'id_hoja_de_enfermeria': row['id_hoja_de_enfermeria'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return solicitudesMedicamento;
  }

  // Obtener un registro por ID de la tabla Solicitud_Medicamento
  Future<Map<String, dynamic>?> getById(int idSolicitudMedicamento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query(
        'SELECT * FROM Solicitud_Medicamento WHERE id_solicitud_medicamento = ?',
        [idSolicitudMedicamento]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_solicitud_medicamento': row['id_solicitud_medicamento'],
        'concentracion': row['concentracion'],
        'cantidad_presentacion': row['cantidad_presentacion'],
        'nombre': row['nombre'],
        'marca': row['marca'],
        'tipo': row['tipo'],
        'id_hoja_de_enfermeria': row['id_hoja_de_enfermeria'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Solicitud_Medicamento
  Future<void> insert(Map<String, dynamic> solicitudMedicamento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO Solicitud_Medicamento (concentracion, cantidad_presentacion, nombre, marca, tipo, id_hoja_de_enfermeria) VALUES (?, ?, ?, ?, ?, ?)',
      [
        solicitudMedicamento['concentracion'],
        solicitudMedicamento['cantidad_presentacion'],
        solicitudMedicamento['nombre'],
        solicitudMedicamento['marca'],
        solicitudMedicamento['tipo'],
        solicitudMedicamento['id_hoja_de_enfermeria'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Solicitud_Medicamento
  Future<void> update(int idSolicitudMedicamento,
      Map<String, dynamic> solicitudMedicamento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE Solicitud_Medicamento SET concentracion = ?, cantidad_presentacion = ?, nombre = ?, marca = ?, tipo = ?, id_hoja_de_enfermeria = ? WHERE id_solicitud_medicamento = ?',
      [
        solicitudMedicamento['concentracion'],
        solicitudMedicamento['cantidad_presentacion'],
        solicitudMedicamento['nombre'],
        solicitudMedicamento['marca'],
        solicitudMedicamento['tipo'],
        solicitudMedicamento['id_hoja_de_enfermeria'],
        idSolicitudMedicamento,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Solicitud_Medicamento
  Future<void> delete(int idSolicitudMedicamento) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
        'DELETE FROM Solicitud_Medicamento WHERE id_solicitud_medicamento = ?',
        [idSolicitudMedicamento]);
    await DatabaseHelper.closeConnection(conn);
  }
}
