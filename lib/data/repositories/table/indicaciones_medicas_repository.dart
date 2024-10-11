// Repositorio para la tabla Indicaciones_Medicas
// repositories/indicaciones_medicas_repository.dart
import 'package:mysql1/mysql1.dart';
import '../../providers/database_helper.dart';

class IndicacionesMedicasRepository {
  // Obtener todos los registros de la tabla Indicaciones_Medicas
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM indicaciones_medicas');

    List<Map<String, dynamic>> indicacionesMedicas = [];
    for (var row in results) {
      indicacionesMedicas.add({
        'id_indicaciones_medicas': row['id_indicaciones_medicas'],
        'solicitud_medicamento': row['solicitud_medicamento'],
        'formula': row['formula'],
        'nutricion': row['nutricion'],
        'soluciones': row['soluciones'],
        'lntp': row['lntp'],
        'indicaciones': row['indicaciones'],
        'diagnostico': row['diagnostico'],
        'lve': row['lve'],
        'ret': row['ret'],
        'fecha': row['fecha'],
        'medidas': row['medidas'],
        'pendientes': row['pendientes'],
        'cuidados': row['cuidados'],
        'nss_paciente': row['nss_paciente'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return indicacionesMedicas;
  }

  // Obtener un registro por ID de la tabla Indicaciones_Medicas
  Future<Map<String, dynamic>?> getById(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query(
        'SELECT * FROM indicaciones_medicas WHERE id_indicaciones_medicas = ?',
        [id]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_indicaciones_medicas': row['id_indicaciones_medicas'],
        'solicitud_medicamento': row['solicitud_medicamento'],
        'formula': row['formula'],
        'nutricion': row['nutricion'],
        'soluciones': row['soluciones'],
        'lntp': row['lntp'],
        'indicaciones': row['indicaciones'],
        'diagnostico': row['diagnostico'],
        'lve': row['lve'],
        'ret': row['ret'],
        'fecha': row['fecha'],
        'medidas': row['medidas'],
        'pendientes': row['pendientes'],
        'cuidados': row['cuidados'],
        'nss_paciente': row['nss_paciente'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Indicaciones_Medicas
  Future<void> insert(Map<String, dynamic> indicacionesMedicas) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO indicaciones_medicas (solicitud_medicamento, formula, nutricion, soluciones, lntp, indicaciones, diagnostico, lve, ret, fecha, medidas, pendientes, cuidados, nss_paciente) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        indicacionesMedicas['solicitud_medicamento'],
        indicacionesMedicas['formula'],
        indicacionesMedicas['nutricion'],
        indicacionesMedicas['soluciones'],
        indicacionesMedicas['lntp'],
        indicacionesMedicas['indicaciones'],
        indicacionesMedicas['diagnostico'],
        indicacionesMedicas['lve'],
        indicacionesMedicas['ret'],
        indicacionesMedicas['fecha'],
        indicacionesMedicas['medidas'],
        indicacionesMedicas['pendientes'],
        indicacionesMedicas['cuidados'],
        indicacionesMedicas['nss_paciente'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Indicaciones_Medicas
  Future<void> update(int id, Map<String, dynamic> indicacionesMedicas) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE indicaciones_medicas SET solicitud_medicamento = ?, formula = ?, nutricion = ?, soluciones = ?, lntp = ?, indicaciones = ?, diagnostico = ?, lve = ?, ret = ?, fecha = ?, medidas = ?, pendientes = ?, cuidados = ?, nss_paciente = ? WHERE id_indicaciones_medicas = ?',
      [
        indicacionesMedicas['solicitud_medicamento'],
        indicacionesMedicas['formula'],
        indicacionesMedicas['nutricion'],
        indicacionesMedicas['soluciones'],
        indicacionesMedicas['lntp'],
        indicacionesMedicas['indicaciones'],
        indicacionesMedicas['diagnostico'],
        indicacionesMedicas['lve'],
        indicacionesMedicas['ret'],
        indicacionesMedicas['fecha'],
        indicacionesMedicas['medidas'],
        indicacionesMedicas['pendientes'],
        indicacionesMedicas['cuidados'],
        indicacionesMedicas['nss_paciente'],
        id,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Indicaciones_Medicas
  Future<void> delete(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
        'DELETE FROM indicaciones_medicas WHERE id_indicaciones_medicas = ?',
        [id]);
    await DatabaseHelper.closeConnection(conn);
  }
}
