import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/content_item.dart';
import '../utils/formatters.dart';
import '../utils/price_history.dart';
import 'change_pill.dart';
import 'currency_scope.dart';

/// Tarjeta con la evolución del precio (7 o 30 días). El histórico es
/// simulado, y la tarjeta lo dice.
class PriceChartCard extends StatefulWidget {
  const PriceChartCard({super.key, required this.asset});

  final ContentItem asset;

  @override
  State<PriceChartCard> createState() => _PriceChartCardState();
}

class _PriceChartCardState extends State<PriceChartCard> {
  int _days = 30;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = priceHistory(widget.asset);
    if (history.length < 3) return const SizedBox.shrink();

    final shown = _days == 7 ? history.sublist(history.length - 8) : history;
    final first = shown.first;
    final last = shown.last;
    final change = first == 0 ? 0.0 : (last - first) / first * 100;
    final color = AppColors.change(context, change);
    final low = shown.reduce(math.min);
    final high = shown.reduce(math.max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Evolución del precio',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                for (final d in const [7, 30])
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ChoiceChip(
                      label: Text('${d}D'),
                      selected: _days == d,
                      showCheckmark: false,
                      visualDensity: VisualDensity.compact,
                      onSelected: (_) => setState(() => _days = d),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                ChangePill(value: change, compact: true),
                const SizedBox(width: 8),
                Text(
                  'en $_days días',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: CustomPaint(
                size: Size.infinite,
                painter: _LinePainter(values: shown, color: color),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mín ${context.money(low)}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'Máx ${context.money(high)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Histórico simulado con fines educativos '
              '(variación ${Fmt.percent(change)}).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final span = (maxV - minV) == 0 ? 1.0 : (maxV - minV);

    const padX = 6.0;
    const padTop = 12.0;
    const padBottom = 12.0;
    final w = size.width - padX * 2;
    final h = size.height - padTop - padBottom;

    final pts = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(
          padX + w * i / (values.length - 1),
          padTop + h * (1 - (values[i] - minV) / span),
        ),
    ];

    // Línea suavizada con curvas.
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final prev = pts[i - 1];
      final cur = pts[i];
      final midX = (prev.dx + cur.dx) / 2;
      path.cubicTo(midX, prev.dy, midX, cur.dy, cur.dx, cur.dy);
    }

    // Relleno degradado bajo la línea.
    final fill = Path.from(path)
      ..lineTo(pts.last.dx, size.height)
      ..lineTo(pts.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.0)],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Punto del precio actual.
    canvas.drawCircle(pts.last, 5.5, Paint()..color = color);
    canvas.drawCircle(pts.last, 2.4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.values != values || old.color != color;
}
