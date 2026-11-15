import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../utils/formatters.dart';

/// Etiqueta con flecha y porcentaje: verde si sube, roja si baja.
class ChangePill extends StatelessWidget {
  const ChangePill({super.key, required this.value, this.compact = false});

  final double value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.change(context, value);
    final up = value >= 0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: color,
            size: compact ? 18 : 22,
          ),
          Text(
            Fmt.percent(value, signed: false),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 12 : 14,
            ),
          ),
          SizedBox(width: compact ? 4 : 6),
        ],
      ),
    );
  }
}
