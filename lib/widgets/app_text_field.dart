import 'package:flutter/material.dart';

/// Campo de texto reutilizable para toda la app.
///
/// Envuelve un [TextFormField] con una decoración consistente:
/// etiqueta, hint, ícono y borde. Todos los parámetros son opcionales
/// excepto [label], para que se pueda adaptar a distintos formularios
/// (login, registro, etc.).
///
/// Es un [StatelessWidget] porque no guarda estado propio:
/// todo lo que muestra le llega por parámetros.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.hint,
    this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
  });

  /// Texto que se muestra como etiqueta del campo.
  final String label;

  /// Controlador externo que guarda lo que escribe el usuario.
  final TextEditingController? controller;

  /// Función de validación. Devuelve null si es válido.
  final String? Function(String?)? validator;

  /// Texto de ayuda dentro del campo (ej: "nombre@correo.com").
  final String? hint;

  /// Ícono que se muestra a la izquierda.
  final IconData? icon;

  /// Tipo de teclado (email, número, texto, etc.).
  final TextInputType? keyboardType;

  /// Qué hace la tecla "Enter" del teclado móvil.
  final TextInputAction? textInputAction;

  /// Si es true, oculta el texto (para contraseñas).
  final bool obscureText;

  /// Número máximo de líneas visibles.
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
