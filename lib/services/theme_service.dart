import 'package:flutter/material.dart';

/// Servicio que controla el tema de la app (claro / oscuro).
///
/// Usa un [ValueNotifier] para que cualquier widget pueda "escuchar"
/// los cambios de tema y reconstruirse automáticamente.
class ThemeService {
  // Constructor privado: no se puede instanciar la clase,
  // todo se usa de forma estática.
  ThemeService._();

  /// Modo de tema actual (light o dark).
  static final ValueNotifier<ThemeMode> mode = ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );

  /// Alterna entre claro y oscuro.
  static void toggle() {
    mode.value = mode.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  /// Atajo para saber si está en modo oscuro.
  static bool get isDark => mode.value == ThemeMode.dark;
}
