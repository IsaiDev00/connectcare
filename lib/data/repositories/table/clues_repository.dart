// Repositorio para la tabla CLUES_Registros
// repositories/clues_registros_repository.dart
import 'package:mysql1/mysql1.dart';
import '../../providers/database_helper.dart';

class CluesRegistrosRepository {
  // Obtener todos los registros de la tabla CLUES_Registros
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM CLUES_Registros');

    List<Map<String, dynamic>> cluesRegistros = [];
    for (var row in results) {
      cluesRegistros.add({
        'clues': row['clues'],
        'nombre_institucion': row['nombre_institucion'],
        'entidad': row['entidad'],
        'municipio': row['municipio'],
        'estatus_operacion': row['estatus_operacion'],
        'codigo_postal': row['codigo_postal'],
        'vialidad': row['vialidad'],
        'numero_exterior': row['numero_exterior'],
        'tipo_vialidad': row['tipo_vialidad'],
        'tipo_asentamiento': row['tipo_asentamiento'],
        'asentamiento': row['asentamiento'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return cluesRegistros;
  }

  // Obtener un registro por CLUES de la tabla CLUES_Registros
  Future<Map<String, dynamic>?> getByClues(String clues) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM CLUES_Registros WHERE clues = ?', [clues]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'clues': row['clues'],
        'nombre_institucion': row['nombre_institucion'],
        'entidad': row['entidad'],
        'municipio': row['municipio'],
        'estatus_operacion': row['estatus_operacion'],
        'codigo_postal': row['codigo_postal'],
        'vialidad': row['vialidad'],
        'numero_exterior': row['numero_exterior'],
        'tipo_vialidad': row['tipo_vialidad'],
        'tipo_asentamiento': row['tipo_asentamiento'],
        'asentamiento': row['asentamiento'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla CLUES_Registros
  Future<void> insert(Map<String, dynamic> cluesRegistro) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO CLUES_Registros (clues, nombre_institucion, entidad, municipio, estatus_operacion, codigo_postal, vialidad, numero_exterior, tipo_vialidad, tipo_asentamiento, asentamiento) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        cluesRegistro['clues'],
        cluesRegistro['nombre_institucion'],
        cluesRegistro['entidad'],
        cluesRegistro['municipio'],
        cluesRegistro['estatus_operacion'],
        cluesRegistro['codigo_postal'],
        cluesRegistro['vialidad'],
        cluesRegistro['numero_exterior'],
        cluesRegistro['tipo_vialidad'],
        cluesRegistro['tipo_asentamiento'],
        cluesRegistro['asentamiento'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla CLUES_Registros
  Future<void> update(String clues, Map<String, dynamic> cluesRegistro) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE CLUES_Registros SET nombre_institucion = ?, entidad = ?, municipio = ?, estatus_operacion = ?, codigo_postal = ?, vialidad = ?, numero_exterior = ?, tipo_vialidad = ?, tipo_asentamiento = ?, asentamiento = ? WHERE clues = ?',
      [
        cluesRegistro['nombre_institucion'],
        cluesRegistro['entidad'],
        cluesRegistro['municipio'],
        cluesRegistro['estatus_operacion'],
        cluesRegistro['codigo_postal'],
        cluesRegistro['vialidad'],
        cluesRegistro['numero_exterior'],
        cluesRegistro['tipo_vialidad'],
        cluesRegistro['tipo_asentamiento'],
        cluesRegistro['asentamiento'],
        clues,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla CLUES_Registros
  Future<void> delete(String clues) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query('DELETE FROM CLUES_Registros WHERE clues = ?', [clues]);
    await DatabaseHelper.closeConnection(conn);
  }
}