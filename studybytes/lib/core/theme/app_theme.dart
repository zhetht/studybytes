import 'package:flutter/material.dart';

class AppTheme {
  // Colores base
  static const Color darkBg = Color(0xFF0A0A0A);
  static const Color cardDark = Color(0xFF1A1A1A);
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color mint = Color(0xFF00D4AA);
  
  // ✅ COLORES FALTANTES - AGREGAR ESTOS:
  static const Color lavender = Color(0xFF9B59B6);  // Morado lavanda
  static const Color pink = Color(0xFFE91E63);     // Rosa
  
  // colores adicionales que podrías necesitar
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFC107);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: darkBg,
    useMaterial3: true,
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: Colors.white, fontSize: 20),
      bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white60, fontSize: 14),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.white38),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}