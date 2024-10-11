// Repositorio para la tabla Nota_De_Evolucion
// repositories/nota_de_evolucion_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class NotaDeEvolucionRepository {
  // Obtener todos los registros de la tabla Nota_De_Evolucion
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM nota_de_evolucion');

    List<Map<String, dynamic>> notasDeEvolucion = [];
    for (var row in results) {
      notasDeEvolucion.add({
        'id_nota_de_evolucion': row['id_nota_de_evolucion'],
        'saturacion_oxigeno': row['saturacion_oxigeno'],
        'temperatura': row['temperatura'],
        'frecuencia_cardiaca': row['frecuencia_cardiaca'],
        'frecuencia_respiratoria': row['frecuencia_respiratoria'],
        'ta_diastolica': row['ta_diastolica'],
        'ta_sistolica': row['ta_sistolica'],
        'evolucion': row['evolucion'],
        'somatometria': row['somatometria'],
        'exploracion_fisica': row['exploracion_fisica'],
        'laboratorio': row['laboratorio'],
        'imagen': row['imagen'],
        'diagnostico': row['diagnostico'],
        'plan': row['plan'],
        'pronostico': row['pronostico'],
        'comentario': row['comentario'],
        'nota': row['nota'],
        'destino_hospitalario': row['destino_hospitalario'],
        'resultado_cultivo': row['resultado_cultivo'],
        'fecha_solicitud_cultivo': row['fecha_solicitud_cultivo'],
        'infeccion_nosocomial': row['infeccion_nosocomial'],
        'fecha_intubacion': row['fecha_intubacion'],
        'fecha_cateter': row['fecha_cateter'],
        'nss_paciente': row['nss_paciente'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return notasDeEvolucion;
  }

  // Obtener un registro por ID de la tabla Nota_De_Evolucion
  Future<Map<String, dynamic>?> getById(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query(
        'SELECT * FROM nota_de_evolucion WHERE id_nota_de_evolucion = ?', [id]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'id_nota_de_evolucion': row['id_nota_de_evolucion'],
        'saturacion_oxigeno': row['saturacion_oxigeno'],
        'temperatura': row['temperatura'],
        'frecuencia_cardiaca': row['frecuencia_cardiaca'],
        'frecuencia_respiratoria': row['frecuencia_respiratoria'],
        'ta_diastolica': row['ta_diastolica'],
        'ta_sistolica': row['ta_sistolica'],
        'evolucion': row['evolucion'],
        'somatometria': row['somatometria'],
        'exploracion_fisica': row['exploracion_fisica'],
        'laboratorio': row['laboratorio'],
        'imagen': row['imagen'],
        'diagnostico': row['diagnostico'],
        'plan': row['plan'],
        'pronostico': row['pronostico'],
        'comentario': row['comentario'],
        'nota': row['nota'],
        'destino_hospitalario': row['destino_hospitalario'],
        'resultado_cultivo': row['resultado_cultivo'],
        'fecha_solicitud_cultivo': row['fecha_solicitud_cultivo'],
        'infeccion_nosocomial': row['infeccion_nosocomial'],
        'fecha_intubacion': row['fecha_intubacion'],
        'fecha_cateter': row['fecha_cateter'],
        'nss_paciente': row['nss_paciente'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Nota_De_Evolucion
  Future<void> insert(Map<String, dynamic> notaDeEvolucion) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO nota_de_evolucion (saturacion_oxigeno, temperatura, frecuencia_cardiaca, frecuencia_respiratoria, ta_diastolica, ta_sistolica, evolucion, somatometria, exploracion_fisica, laboratorio, imagen, diagnostico, plan, pronostico, comentario, nota, destino_hospitalario, resultado_cultivo, fecha_solicitud_cultivo, infeccion_nosocomial, fecha_intubacion, fecha_cateter, nss_paciente) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        notaDeEvolucion['saturacion_oxigeno'],
        notaDeEvolucion['temperatura'],
        notaDeEvolucion['frecuencia_cardiaca'],
        notaDeEvolucion['frecuencia_respiratoria'],
        notaDeEvolucion['ta_diastolica'],
        notaDeEvolucion['ta_sistolica'],
        notaDeEvolucion['evolucion'],
        notaDeEvolucion['somatometria'],
        notaDeEvolucion['exploracion_fisica'],
        notaDeEvolucion['laboratorio'],
        notaDeEvolucion['imagen'],
        notaDeEvolucion['diagnostico'],
        notaDeEvolucion['plan'],
        notaDeEvolucion['pronostico'],
        notaDeEvolucion['comentario'],
        notaDeEvolucion['nota'],
        notaDeEvolucion['destino_hospitalario'],
        notaDeEvolucion['resultado_cultivo'],
        notaDeEvolucion['fecha_solicitud_cultivo'],
        notaDeEvolucion['infeccion_nosocomial'],
        notaDeEvolucion['fecha_intubacion'],
        notaDeEvolucion['fecha_cateter'],
        notaDeEvolucion['nss_paciente'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Nota_De_Evolucion
  Future<void> update(int id, Map<String, dynamic> notaDeEvolucion) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE nota_de_evolucion SET saturacion_oxigeno = ?, temperatura = ?, frecuencia_cardiaca = ?, frecuencia_respiratoria = ?, ta_diastolica = ?, ta_sistolica = ?, evolucion = ?, somatometria = ?, exploracion_fisica = ?, laboratorio = ?, imagen = ?, diagnostico = ?, plan = ?, pronostico = ?, comentario = ?, nota = ?, destino_hospitalario = ?, resultado_cultivo = ?, fecha_solicitud_cultivo = ?, infeccion_nosocomial = ?, fecha_intubacion = ?, fecha_cateter = ?, nss_paciente = ? WHERE id_nota_de_evolucion = ?',
      [
        notaDeEvolucion['saturacion_oxigeno'],
        notaDeEvolucion['temperatura'],
        notaDeEvolucion['frecuencia_cardiaca'],
        notaDeEvolucion['frecuencia_respiratoria'],
        notaDeEvolucion['ta_diastolica'],
        notaDeEvolucion['ta_sistolica'],
        notaDeEvolucion['evolucion'],
        notaDeEvolucion['somatometria'],
        notaDeEvolucion['exploracion_fisica'],
        notaDeEvolucion['laboratorio'],
        notaDeEvolucion['imagen'],
        notaDeEvolucion['diagnostico'],
        notaDeEvolucion['plan'],
        notaDeEvolucion['pronostico'],
        notaDeEvolucion['comentario'],
        notaDeEvolucion['nota'],
        notaDeEvolucion['destino_hospitalario'],
        notaDeEvolucion['resultado_cultivo'],
        notaDeEvolucion['fecha_solicitud_cultivo'],
        notaDeEvolucion['infeccion_nosocomial'],
        notaDeEvolucion['fecha_intubacion'],
        notaDeEvolucion['fecha_cateter'],
        notaDeEvolucion['nss_paciente'],
        id,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Nota_De_Evolucion
  Future<void> delete(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
        'DELETE FROM nota_de_evolucion WHERE id_nota_de_evolucion = ?', [id]);
    await DatabaseHelper.closeConnection(conn);
  }
}
