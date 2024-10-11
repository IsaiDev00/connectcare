// Repositorio para la tabla Paciente
// repositories/paciente_repository.dart
import 'package:mysql1/mysql1.dart';
import '../../providers/database_helper.dart';

class PacienteRepository {
  // Obtener todos los registros de la tabla Paciente
  Future<List<Map<String, dynamic>>> getAll() async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn.query('SELECT * FROM paciente');

    List<Map<String, dynamic>> pacientes = [];
    for (var row in results) {
      pacientes.add({
        'nss_paciente': row['nss_paciente'],
        'nombre': row['nombre'],
        'apellido_paterno': row['apellido_paterno'],
        'apellido_materno': row['apellido_materno'],
        'lpm': row['lpm'],
        'estatura': row['estatura'],
        'peso': row['peso'],
        'fecha_entrada': row['fecha_entrada'],
        'habilitar_visita': row['habilitar_visita'],
        'estado': row['estado'],
        'sexo': row['sexo'],
        'fecha_nacimiento': row['fecha_nacimiento'],
        'gpo_y_rh': row['gpo_y_rh'],
        'visitantes': row['visitantes'],
        'alergias': row['alergias'],
        'numero_piso': row['numero_piso'],
      });
    }

    await DatabaseHelper.closeConnection(conn);
    return pacientes;
  }

  // Obtener un registro por ID de la tabla Paciente
  Future<Map<String, dynamic>?> getById(int nssPaciente) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    var results = await conn
        .query('SELECT * FROM paciente WHERE nss_paciente = ?', [nssPaciente]);

    if (results.isNotEmpty) {
      var row = results.first;
      await DatabaseHelper.closeConnection(conn);
      return {
        'nss_paciente': row['nss_paciente'],
        'nombre': row['nombre'],
        'apellido_paterno': row['apellido_paterno'],
        'apellido_materno': row['apellido_materno'],
        'lpm': row['lpm'],
        'estatura': row['estatura'],
        'peso': row['peso'],
        'fecha_entrada': row['fecha_entrada'],
        'habilitar_visita': row['habilitar_visita'],
        'estado': row['estado'],
        'sexo': row['sexo'],
        'fecha_nacimiento': row['fecha_nacimiento'],
        'gpo_y_rh': row['gpo_y_rh'],
        'visitantes': row['visitantes'],
        'alergias': row['alergias'],
        'numero_piso': row['numero_piso'],
      };
    }

    await DatabaseHelper.closeConnection(conn);
    return null;
  }

  // Insertar un nuevo registro en la tabla Paciente
  Future<void> insert(Map<String, dynamic> paciente) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'INSERT INTO paciente (nombre, apellido_paterno, apellido_materno, lpm, estatura, peso, fecha_entrada, habilitar_visita, estado, sexo, fecha_nacimiento, gpo_y_rh, visitantes, alergias, numero_piso) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        paciente['nombre'],
        paciente['apellido_paterno'],
        paciente['apellido_materno'],
        paciente['lpm'],
        paciente['estatura'],
        paciente['peso'],
        paciente['fecha_entrada'],
        paciente['habilitar_visita'],
        paciente['estado'],
        paciente['sexo'],
        paciente['fecha_nacimiento'],
        paciente['gpo_y_rh'],
        paciente['visitantes'],
        paciente['alergias'],
        paciente['numero_piso'],
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Actualizar un registro en la tabla Paciente
  Future<void> update(int nssPaciente, Map<String, dynamic> paciente) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn.query(
      'UPDATE paciente SET nombre = ?, apellido_paterno = ?, apellido_materno = ?, lpm = ?, estatura = ?, peso = ?, fecha_entrada = ?, habilitar_visita = ?, estado = ?, sexo = ?, fecha_nacimiento = ?, gpo_y_rh = ?, visitantes = ?, alergias = ?, numero_piso = ? WHERE nss_paciente = ?',
      [
        paciente['nombre'],
        paciente['apellido_paterno'],
        paciente['apellido_materno'],
        paciente['lpm'],
        paciente['estatura'],
        paciente['peso'],
        paciente['fecha_entrada'],
        paciente['habilitar_visita'],
        paciente['estado'],
        paciente['sexo'],
        paciente['fecha_nacimiento'],
        paciente['gpo_y_rh'],
        paciente['visitantes'],
        paciente['alergias'],
        paciente['numero_piso'],
        nssPaciente,
      ],
    );
    await DatabaseHelper.closeConnection(conn);
  }

  // Eliminar un registro en la tabla Paciente
  Future<void> delete(int nssPaciente) async {
    MySqlConnection conn = await DatabaseHelper.getConnection();
    await conn
        .query('DELETE FROM paciente WHERE nss_paciente = ?', [nssPaciente]);
    await DatabaseHelper.closeConnection(conn);
  }
}
