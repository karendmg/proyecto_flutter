import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/content_item.dart';
import '../models/portfolio_models.dart';
import '../utils/formatters.dart';

/// Distribución del portafolio: una barra apilada con un color por categoría
/// (más el efectivo) y una leyenda con el porcentaje de cada una.
class AllocationCard extends StatelessWidget {
  const AllocationCard({
    super.key,
    required this.holdings,
    required this.byId,
    required this.cash,
  });

  final List<Holding> holdings;
  final Map<String, ContentItem> byId;

  /// Efectivo disponible, en dólares (entra como una "categoría" más).
  final double cash;

  /// Alto de la barra de colores.
  static const double barHeight = 14;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Suma el valor actual de cada categoría y agrega el efectivo al final.
    final totals = <String, double>{};
    for (final h in holdings) {
      final asset = byId[h.assetId];
      final price = asset?.price ?? h.avgPrice;
      final category = asset?.category ?? h.category;
      final key = category.isEmpty ? 'Otros' : category;
      totals[key] = (totals[key] ?? 0) + price * h.shares;
    }
    if (cash > 0) totals['Efectivo'] = cash;

    final entries = totals.entries.where((e) => e.value > 0).toList();
    final sum = entries.fold<double>(0, (s, e) => s + e.value);
    if (sum <= 0) return const SizedBox.shrink();

    Color colorAt(int i) => AppColors.palette[i % AppColors.palette.length];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: barHeight,
                // stretch: cada segmento recibe la altura completa de la barra.
                // (Sin esto, un segmento sin hijo mide 0 de alto y la barra
                // no se ve.)
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < entries.length; i++)
                      Expanded(
                        flex: _flex(entries[i].value / sum),
                        child: Padding(
                          padding: EdgeInsets.only(left: i == 0 ? 0 : 2),
                          child: Container(
                            key: ValueKey('allocation-segment-$i'),
                            color: colorAt(i),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                for (var i = 0; i < entries.length; i++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colorAt(i),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${entries[i].key} · '
                        '${Fmt.percent(entries[i].value / sum * 100, signed: false, decimals: 1)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Peso del segmento en la barra (mínimo 1 para que siempre se vea algo).
  static int _flex(double fraction) {
    final f = (fraction * 1000).round();
    return f < 1 ? 1 : f;
  }
}
