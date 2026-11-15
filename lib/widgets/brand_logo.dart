import 'package:flutter/material.dart';

import '../config/theme.dart';

/// Logo de la app: cuadrado redondeado con degradado verde y flecha ascendente.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(Icons.trending_up, color: Colors.white, size: size * 0.58),
    );
  }
}
