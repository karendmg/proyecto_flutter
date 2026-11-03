import 'package:flutter/material.dart';

/// Botón principal de la app.
///
/// Envuelve un [FilledButton] con:
///   - ancho completo (ocupa todo el ancho disponible),
///   - bordes redondeados,
///   - altura fija cómoda para el dedo,
///   - indicador de carga opcional ([isLoading]).
///
/// Cuando [isLoading] es true, el botón:
///   - se deshabilita (no se puede pulsar de nuevo),
///   - muestra un spinner en lugar del texto.
///
/// Esto evita envíos dobles: por ejemplo, si el usuario pulsa "Iniciar sesión"
/// varias veces mientras el backend responde.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  /// Texto que se muestra en el botón.
  final String label;

  /// Función que se ejecuta al pulsar.
  /// Si es null, el botón queda deshabilitado.
  final VoidCallback? onPressed;

  /// Si es true, muestra un spinner y deshabilita el botón.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      // Si está cargando, onPressed se pone null para deshabilitar.
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        // Ancho completo y altura de 52.
        minimumSize: const Size.fromHeight(52),
        // Bordes redondeados.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: isLoading
          // Mientras carga: spinner blanco chiquito.
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          // Normal: texto del botón.
          : Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}
