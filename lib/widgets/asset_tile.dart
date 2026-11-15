import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/content_item.dart';
import 'change_pill.dart';
import 'currency_scope.dart';

/// Ícono cuadrado redondeado según la categoría del activo.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.category, this.size = 44});

  final String category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        AppIcons.forCategory(category),
        color: scheme.onPrimaryContainer,
        size: size * 0.5,
      ),
    );
  }
}

/// Fila de un activo: ícono, nombre, categoría, precio y variación.
class AssetTile extends StatelessWidget {
  const AssetTile({
    super.key,
    required this.asset,
    this.owned = 0,
    this.isFavorite = false,
    this.onTap,
  });

  final ContentItem asset;

  /// Unidades que el usuario tiene de este activo (0 = no muestra nada).
  final int owned;

  /// Si está en favoritos, muestra una estrella junto al nombre.
  final bool isFavorite;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CategoryBadge(category: asset.category),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            asset.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isFavorite) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFF59E0B),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      asset.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                    if (owned > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Tienes $owned u.',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyText(
                    asset.price,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ChangePill(value: asset.changePercent, compact: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
