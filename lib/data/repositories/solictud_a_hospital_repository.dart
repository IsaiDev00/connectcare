// Repositorio para la tabla Solicitud_A_Hospital
// repositories/solicitud_a_hospital_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class SolicitudAHospitalRepository {
  // Obtener todos los registros de la tabla Solicitud_A_Hospital
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM solicitud_a_hospital');

    List<Map<String, dynamic>> solicitudesHospital = [];
    for (var row in results) {
      solicitudesHospital.add({
        'id_solicitud_a_hospital': row['id_solicitud_a_hospital'],
        'fecha': row['fecha'],
        'peticion': row['peticion'],
        'clues': row['clues'],
        'id_personal_no_asignado': row['id_personal_no_asignado'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return solicitudesHospital;
  }

  // Obtener un registro por ID de la tabla Solicitud_A_Hospital
  Future<Map<String, dynamic>?> getById(int idSolicitudAHospital) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query(
        'SELECT * FROM solicitud_a_hospital WHERE id_solicitud_a_hospital = ?',
        [idSolicitudAHospital]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_solicitud_a_hospital': row['id_solicitud_a_hospital'],
        'fecha': row['fecha'],
        'peticion': row['peticion'],
        'clues': row['clues'],
        'id_personal_no_asignado': row['id_personal_no_asignado'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Solicitud_A_Hospital
  Future<void> insert(Map<String, dynamic> solicitudAHospital) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO solicitud_a_hospital (fecha, peticion, clues, id_personal_no_asignado) VALUES (?, ?, ?, ?)',
      [
        solicitudAHospital['fecha'],
        solicitudAHospital['peticion'],
        solicitudAHospital['clues'],
        solicitudAHospital['id_personal_no_asignado'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Solicitud_A_Hospital
  Future<void> update(
      int idSolicitudAHospital, Map<String, dynamic> solicitudAHospital) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE solicitud_a_hospital SET fecha = ?, peticion = ?, clues = ?, id_personal_no_asignado = ? WHERE id_solicitud_a_hospital = ?',
      [
        solicitudAHospital['fecha'],
        solicitudAHospital['peticion'],
        solicitudAHospital['clues'],
        solicitudAHospital['id_personal_no_asignado'],
        idSolicitudAHospital,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Solicitud_A_Hospital
  Future<void> delete(int idSolicitudAHospital) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
        'DELETE FROM solicitud_a_hospital WHERE id_solicitud_a_hospital = ?',
        [idSolicitudAHospital]);
    await DatabaseHelper.closeConnection(conn);
  }
}
