// Repositorio para la tabla Hospital
// repositories/hospital_repository.dart
import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class HospitalRepository {
  // Obtener todos los registros de la tabla Hospital
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM hospital');

    List<Map<String, dynamic>> hospitales = [];
    for (var row in results) {
      hospitales.add({
        'clues': row['clues'],
        'colonia': row['colonia'],
        'estatus': row['estatus'],
        'cp': row['cp'],
        'calle': row['calle'],
        'numero_calle': row['numero_calle'],
        'estado': row['estado'],
        'municipio': row['municipio'],
        'nombre': row['nombre'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return hospitales;
  }

  // Obtener un registro por ID de la tabla Hospital
  Future<Map<String, dynamic>?> getById(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results =
        await conn.query('SELECT * FROM hospital WHERE clues = ?', [id]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'clues': row['clues'],
        'colonia': row['colonia'],
        'estatus': row['estatus'],
        'cp': row['cp'],
        'calle': row['calle'],
        'numero_calle': row['numero_calle'],
        'estado': row['estado'],
        'municipio': row['municipio'],
        'nombre': row['nombre'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Hospital
  Future<void> insert(Map<String, dynamic> hospital) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO hospital (colonia, estatus, cp, calle, numero_calle, estado, municipio, nombre) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        hospital['colonia'],
        hospital['estatus'],
        hospital['cp'],
        hospital['calle'],
        hospital['numero_calle'],
        hospital['estado'],
        hospital['municipio'],
        hospital['nombre'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Hospital
  Future<void> update(int id, Map<String, dynamic> hospital) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE hospital SET colonia = ?, estatus = ?, cp = ?, calle = ?, numero_calle = ?, estado = ?, municipio = ?, nombre = ? WHERE clues = ?',
      [
        hospital['colonia'],
        hospital['estatus'],
        hospital['cp'],
        hospital['calle'],
        hospital['numero_calle'],
        hospital['estado'],
        hospital['municipio'],
        hospital['nombre'],
        id,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Hospital
  Future<void> delete(int id) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query('DELETE FROM hospital WHERE clues = ?', [id]);
    await DatabaseHelper.closeConnection(conn);
  }
}
