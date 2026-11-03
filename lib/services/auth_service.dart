import 'package:flutter/foundation.dart';

/// Servicio de autenticación (simulado por ahora).
///
/// En el futuro, aquí se conectará el backend real con llamadas HTTP.
/// Por ahora simula el login/registro con un pequeño retraso, como si
/// estuviera consultando una API.
///
/// Es un [ChangeNotifier] para que los widgets puedan escuchar los
/// cambios: por ejemplo, cuando el usuario inicia sesión, la pantalla
/// se reconstruye automáticamente.
class AuthService extends ChangeNotifier {
  // Constructor privado y singleton: solo existe UNA instancia
  // de este servicio en toda la app.
  AuthService._();
  static final AuthService instance = AuthService._();

  bool _loggedIn = false;
  String _name = '';
  String _email = '';

  // ---------------- Getters ----------------

  bool get isLoggedIn => _loggedIn;

  String get userName => _name.isEmpty ? 'Inversionista' : _name;

  String get userEmail => _email;

  // ---------------- Acciones ----------------

  /// Simula el login contra una API.
  /// Devuelve true si las credenciales son válidas, false si no.
  Future<bool> login(String email, String password) async {
    // Simula el tiempo de respuesta del servidor (1 segundo).
    await Future.delayed(const Duration(seconds: 1));

    if (email.trim().isEmpty || password.length < 6) {
      return false;
    }

    _email = email.trim();
    _name = _capitalize(email.split('@').first);
    _loggedIn = true;

    // Notifica a los widgets suscritos que el estado cambió.
    notifyListeners();
    return true;
  }

  /// Simula el registro de un nuevo usuario.
  Future<bool> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    _name = name.trim();
    _email = email.trim();
    _loggedIn = true;

    notifyListeners();
    return true;
  }

  /// Cierra la sesión y limpia los datos del usuario.
  void logout() {
    _loggedIn = false;
    _name = '';
    _email = '';

    notifyListeners();
  }

  // ---------------- Helpers ----------------

  /// Convierte la primera letra de un texto a mayúscula.
  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
