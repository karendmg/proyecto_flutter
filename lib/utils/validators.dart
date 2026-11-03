/// Validadores reutilizables para los formularios de la app.
///
/// Cada validador devuelve:
///   - null      → el valor es válido ✅
///   - String    → mensaje de error que se muestra bajo el campo ❌
///
/// Se usan así en un TextFormField:
///   validator: Validators.email,
class Validators {
  // Constructor privado: no se instancia la clase.
  Validators._();

  /// Valida un correo electrónico.
  static String? email(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }

    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(email)) {
      return 'Correo no válido';
    }

    return null; // válido
  }

  /// Valida una contraseña: mínimo 6 caracteres.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null; // válido
  }

  /// Valida que un campo no esté vacío (para nombre, etc.).
  static String? notEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    return null; // válido
  }

  /// Devuelve un validador que compara el valor con otro campo.
  ///
  /// Uso:
  ///   validator: Validators.confirmPassword(() => _passCtrl.text),
  static String? Function(String?) confirmPassword(String Function() original) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Confirma tu contraseña';
      }
      if (value != original()) {
        return 'Las contraseñas no coinciden';
      }
      return null; // válido
    };
  }
}
