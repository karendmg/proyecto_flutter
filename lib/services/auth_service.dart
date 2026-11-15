import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Autenticación con Firebase. Es un singleton y un [ChangeNotifier]:
/// las pantallas que lo escuchan se actualizan solas cuando cambia la sesión
/// o el perfil del usuario.
class AuthService extends ChangeNotifier {
  AuthService._() {
    _auth.userChanges().listen((_) => notifyListeners());
  }

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Nombre para mostrar: el registrado, o la parte local del correo.
  String get userName {
    final user = _auth.currentUser;
    final name = user?.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = user?.email;
    if (email != null && email.contains('@')) {
      final local = email.split('@').first;
      if (local.isNotEmpty) return local;
    }
    return 'Usuario';
  }

  String get userEmail => _auth.currentUser?.email ?? 'Sin correo';

  Future<void> registrar(String nombre, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final name = nombre.trim();
    if (name.isNotEmpty) {
      await cred.user?.updateDisplayName(name);
      await cred.user?.reload();
    }
    notifyListeners();
  }

  Future<void> ingresar(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Envía el correo para crear una nueva contraseña (en español).
  /// Solo se usa desde la pantalla de recuperación del inicio de sesión.
  Future<void> restablecerContrasena(String email) async {
    await _auth.setLanguageCode('es');
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> salir() => _auth.signOut();

  /// Igual que [mensajeError], pero con textos pensados para recuperar la
  /// contraseña.
  String mensajeErrorRecuperacion(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No encontramos una cuenta con ese correo.';
        case 'invalid-email':
          return 'El correo no es válido.';
        case 'too-many-requests':
          return 'Demasiados intentos. Espera unos minutos e intenta de nuevo.';
        case 'network-request-failed':
          return 'Sin conexión. Revisa tu internet e intenta de nuevo.';
      }
    }
    return mensajeError(error);
  }

  /// Traduce cualquier error a un mensaje entendible para el usuario.
  String mensajeError(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'email-already-in-use' => 'Ese correo ya está registrado.',
        'invalid-email' => 'El correo no es válido.',
        'weak-password' => 'La contraseña es muy débil (mínimo 6 caracteres).',
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' =>
          'Correo o contraseña incorrectos.',
        'user-disabled' => 'Esta cuenta fue deshabilitada.',
        'too-many-requests' =>
          'Demasiados intentos. Espera un momento e intenta de nuevo.',
        'network-request-failed' =>
          'Sin conexión. Revisa tu internet e intenta de nuevo.',
        'operation-not-allowed' =>
          'El acceso con correo no está habilitado en Firebase.',
        _ => 'Error inesperado (${error.code}).',
      };
    }
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}
