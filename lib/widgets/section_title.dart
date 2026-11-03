import 'package:flutter/material.dart';

/// Título de sección reutilizable.
///
/// Se usa para separar visualmente bloques de contenido en listas
/// y páginas largas. Ya trae el padding y el estilo aplicados.
class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.text});

  /// Texto del título.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding: izq=16, arriba=20, der=16, abajo=8
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
