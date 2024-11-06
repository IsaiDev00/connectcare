import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Tema claro
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF00A0A6),
      fontFamily: 'Suisse_Intl',
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF00A0A6),
        onPrimary: Colors.white,
        secondary: Color(0xFF018080),
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        // Eliminamos background y onBackground
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color.fromARGB(255, 53, 53, 53),
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        iconTheme: IconThemeData(color: Colors.black),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00A0A6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w500,
          color: Color.fromARGB(255, 53, 53, 53),
        ),
        headlineSmall: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.w400,
          color: Color.fromARGB(255, 59, 59, 59),
        ),
        bodyLarge: TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.w400,
          color: Color.fromARGB(255, 59, 59, 59),
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(
        textColor: Colors.black,
        borderColor: Colors.grey,
      ),
    );
  }

  // Tema oscuro
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF00A0A6),
      fontFamily: 'Suisse_Intl',
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF00A0A6),
        onPrimary: Colors.white,
        secondary: Color(0xFF018080),
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: Color(0xFF121212),
        onSurface: Colors.white,

        // Eliminamos background y onBackground
      ),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00A0A6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(
        textColor: Colors.white,
        borderColor: Colors.grey,
      ),
    );
  }

  // Método para definir el InputDecorationTheme
  static InputDecorationTheme _inputDecorationTheme({
    required Color textColor,
    required Color borderColor,
  }) {
    return InputDecorationTheme(
      labelStyle: TextStyle(
        fontFamily: 'Suisse_Intl',
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFF00A0A6),
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: borderColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(
          color: Color(0xFF00A0A6),
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
    );
  }
}
