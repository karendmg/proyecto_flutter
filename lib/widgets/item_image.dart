import 'package:flutter/material.dart';

/// Ilustración local (de `assets/images/`) que ocupa todo el espacio que le
/// dé su padre. Si el archivo no existe, muestra un degradado con un ícono.
class ItemImage extends StatelessWidget {
  const ItemImage({
    super.key,
    required this.asset,
    this.icon = Icons.insights,
    this.fit = BoxFit.cover,
  });

  final String asset;
  final IconData icon;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Image.asset(
      asset,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primaryContainer, scheme.secondaryContainer],
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 40,
            color: scheme.onPrimaryContainer.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}
