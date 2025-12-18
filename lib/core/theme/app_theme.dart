// Este archivo es parte de la tem�tica de la aplicaci�n 
import 'package:flutter/material.dart';

/// Configuración central del tema de la aplicación.
/// Utiliza Material 3 para seguir las guías de diseño modernas.
class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.indigo,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
    // Configuración base para inputs
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.indigo,
    brightness: Brightness.dark,
  );
}