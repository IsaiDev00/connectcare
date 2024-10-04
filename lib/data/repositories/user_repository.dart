import 'package:mysql1/mysql1.dart';
import '../providers/database_helper.dart';

class UserRepository {
  // Método para obtener todos los usuarios
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    // Obtener la conexión a la base de datos
    MySqlConnection conn = await DatabaseHelper.getConnection();

    // Ejecutar la consulta SQL
    var results = await conn.query('SELECT id, name, email FROM users');

    // Transformar los resultados a una lista de mapas
    List<Map<String, dynamic>> users = [];
    for (var row in results) {
      users.add({
        'id': row[0],
        'name': row[1],
        'email': row[2],
      });
    }

    // Cerrar la conexión a la base de datos
    await DatabaseHelper.closeConnection(conn);

    return users;
  }
}
