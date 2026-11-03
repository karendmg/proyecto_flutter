import 'package:flutter/material.dart';

/// Define el tema visual de la app (colores, tipografía, formas).
///
/// Usamos [ThemeData] con Material 3 para que toda la app tenga
/// un estilo moderno y consistente. El color base es un verde
/// financiero (0xFF0B6E4F) que da identidad a la marca.
class AppTheme {
  // Constructor privado: no se instancia la clase.
  AppTheme._();

  /// Color semilla: a partir de él, Flutter genera toda la paleta.
  static const Color seed = Color(0xFF0B6E4F);

  /// Tema claro.
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      secondary: const Color(0xFF08A045),
    ),
  );

  /// Tema oscuro.
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      
      
      
      
      seedColor: seed,
      brightness: Brightness.dark,
    ),
  );
}
