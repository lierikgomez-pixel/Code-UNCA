import 'package:flutter/material.dart';

class AppColors {
  static const bosqueProfundo = Color(0xFF14352B); // verde muy oscuro
  static const bosque = Color(0xFF1F4A3A); // verde oscuro
  static const hoja = Color(0xFF4F8A5B); // verde medio
  static const menta = Color(0xFFA9D18E); // verde claro
  static const limon = Color(0xFFF2B43D); // amarillo de acento
  static const panel = Color(0x99143A2E); // panel oscuro translúcido
  static const campo = Color(0x26FFFFFF); // fondo de campos de texto
}

const fondoGradiente = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF123F38), Color(0xFF2E6046), Color(0xFF6C9A5C)],
);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.hoja,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.limon,
    onPrimary: AppColors.bosqueProfundo,
    secondary: AppColors.menta,
    surface: AppColors.bosque,
    onSurface: Colors.white,
    onSurfaceVariant: Colors.white70,
    secondaryContainer: AppColors.limon,
    onSecondaryContainer: AppColors.bosqueProfundo,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.campo,
      labelStyle: const TextStyle(color: Colors.white70),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.limon,
        foregroundColor: AppColors.bosqueProfundo,
        minimumSize: const Size(0, 52),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.limon),
    ),
  );
}
