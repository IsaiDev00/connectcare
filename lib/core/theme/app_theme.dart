import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Tema claro
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xFF00A0A6),
      fontFamily: 'Suisse_Intl',
      colorScheme: ColorScheme.light(
        primary: Color(0xFF00A0A6), // Color principal (Teal claro)
        secondary: Color(0xFF018080), // Color secundario (Verde azulado oscuro)
      ),
      scaffoldBackgroundColor: Colors.white, // Fondo blanco
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color.fromARGB(255, 53, 53, 53),
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        iconTheme:
            IconThemeData(color: Colors.black), // Íconos de AppBar negros
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF00A0A6), // Color del botón
          foregroundColor: Colors.white, // Color del texto
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Bordes redondeados
          ),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w500,
          color: Color.fromARGB(255, 53, 53, 53), // Texto oscuro
        ),
        headlineSmall: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.w400,
          color: Color.fromARGB(255, 59, 59, 59), // Texto oscuro
        ),
        bodyLarge: TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.w400,
          color: Color.fromARGB(255, 59, 59, 59), // Texto oscuro
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(
          Colors.black, Colors.pink), // Tema de los campos de texto
    );
  }

  // Tema oscuro
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xFF00A0A6),
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF00A0A6), // Color principal (Teal claro)
        secondary: Color(0xFF018080), // Color secundario (Verde azulado oscuro)
      ),
      scaffoldBackgroundColor: Colors.black, // Fondo negro
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme:
            IconThemeData(color: Colors.white), // Íconos de AppBar blancos
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF00A0A6), // Color del botón
          foregroundColor: Colors.white, // Color del texto
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w500,
          color: Colors.white, // Texto claro
        ),
        headlineSmall: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.w400,
          color: Colors.white, // Texto claro
        ),
        bodyLarge: TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.w400,
          color: Colors.white, // Texto claro
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(
          Colors.white, Colors.teal), // Tema de los campos de texto
    );
  }

  // Método para actualizar el brillo de los íconos en la barra de estado
  static void updateStatusBarBrightness(ThemeMode themeMode) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: themeMode == ThemeMode.dark
          ? Brightness.light // Íconos blancos en tema oscuro
          : Brightness.dark, // Íconos negros en tema claro
    ));
  }

  // Método para definir el InputDecorationTheme
  static InputDecorationTheme _inputDecorationTheme(
      Color textColor, Color borderColor) {
    return InputDecorationTheme(
      labelStyle: TextStyle(
          fontFamily: 'Suisse_Intl',
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: textColor), // Actualización: Color dinámico según el tema
      floatingLabelStyle: TextStyle(
        color: Color(
            0xFF00A0A6), // Color del labelText cuando el campo está enfocado
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0), // Borde redondeado
        borderSide: BorderSide(
          color: textColor.withOpacity(0.5), // Color del borde
          width: 1.5, // Grosor del borde
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: Color(0xFF00A0A6), // Borde de color cuando está enfocado
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: Colors.red, // Borde rojo en caso de error
          width: 1.5,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
    );
  }
}
