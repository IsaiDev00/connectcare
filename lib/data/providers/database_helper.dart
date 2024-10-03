import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  // Configuración de la conexión a la base de datos
  static final _host =
      '130.211.194.94'; // IP de tu instancia de Google Cloud SQL
  static final _port = 3306; // Puerto por defecto para MySQL
  static final _user = 'root'; // Usuario de la base de datos
  static final _password =
      'F9)qnFKTmujNz|=N'; // Contraseña del usuario de la base de datos
  static final _dbName = 'connectcare-db'; // Nombre de tu base de datos

  // Método estático para obtener una conexión
  static Future<MySqlConnection> getConnection() async {
    var settings = ConnectionSettings(
      host: _host,
      port: _port,
      user: _user,
      password: _password,
      db: _dbName,
    );
    return await MySqlConnection.connect(settings);
  }

  // Método para cerrar la conexión
  static Future<void> closeConnection(MySqlConnection connection) async {
    await connection.close();
  }
}
