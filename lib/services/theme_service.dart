import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda el modo de tema elegido (sistema, claro u oscuro) y lo recuerda
/// la próxima vez que se abra la app.
class ThemeService {
  ThemeService._();

  static const String _key = 'themeMode';

  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  /// Lee la preferencia guardada. Llamar una vez al iniciar la app.
  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      mode.value = switch (prefs.getString(_key)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } catch (_) {
      // Sin almacenamiento: se queda en "sistema".
    }
  }

  static void setMode(ThemeMode value) {
    mode.value = value;
    _save(value);
  }

  static Future<void> _save(ThemeMode value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, value.name);
    } catch (_) {
      // Si no se puede guardar, el cambio igual aplica en esta sesión.
    }
  }
}
