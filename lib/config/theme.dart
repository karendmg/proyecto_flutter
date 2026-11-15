import 'package:flutter/material.dart';

/// Colores propios de la app (los que Material no define: ganancia/pérdida,
/// degradados y la paleta de los gráficos).
class AppColors {
  AppColors._();

  static const Color seed = Color(0xFF0B6E4F); // Verde financiero

  /// Degradado de las tarjetas "hero" (se ve bien en modo claro y oscuro).
  static const List<Color> heroGradient = [Color(0xFF12906A), Color(0xFF064E3B)];

  /// Colores para el gráfico de distribución.
  static const List<Color> palette = [
    Color(0xFF0B6E4F),
    Color(0xFF2E86DE),
    Color(0xFFF59E0B),
    Color(0xFF8E44AD),
    Color(0xFFE15759),
    Color(0xFF14B8A6),
  ];

  static bool _isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  static Color gain(BuildContext c) =>
      _isDark(c) ? const Color(0xFF4ADE80) : const Color(0xFF138A4E);

  static Color loss(BuildContext c) =>
      _isDark(c) ? const Color(0xFFFF7B85) : const Color(0xFFC62F3A);

  /// Verde si [value] >= 0, rojo si es negativo.
  static Color change(BuildContext c, double value) =>
      value >= 0 ? gain(c) : loss(c);
}

/// Íconos por categoría de activo.
class AppIcons {
  AppIcons._();

  static IconData forCategory(String category) {
    switch (category) {
      case 'Renta variable':
        return Icons.show_chart;
      case 'Renta fija':
        return Icons.account_balance;
      case 'Bienes raíces':
        return Icons.apartment;
      case 'Materias primas':
        return Icons.monetization_on_outlined;
      case 'Efectivo':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.insights;
    }
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );
    final isDark = brightness == Brightness.dark;
    final cardColor =
        isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLowest;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor:
            isDark ? scheme.surfaceContainer : scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: isDark ? scheme.surfaceContainer : scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
