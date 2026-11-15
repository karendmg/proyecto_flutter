import 'package:flutter/material.dart';

import '../services/currency_service.dart';
import '../services/portfolio_service.dart';
import '../services/theme_service.dart';
import '../widgets/currency_scope.dart';

/// Configuración: apariencia, moneda y simulador.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _snack(ScaffoldMessengerState messenger, String text) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _refreshRate(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await CurrencyService.instance.refreshRate();
    _snack(
      messenger,
      ok
          ? 'Tasa actualizada.'
          : 'No se pudo actualizar. Se usa la última tasa guardada.',
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reiniciar simulador'),
        content: Text(
          'Se borrarán tus posiciones y tu historial, y tu efectivo volverá a '
          '${CurrencyService.instance.format(kInitialCash)}. '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final result = await PortfolioService.instance.resetSimulator();
    _snack(messenger, result.message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onSurfaceVariant;
    final currency = CurrencyScope.of(context);

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          // ---------- Apariencia ----------
          header('Apariencia'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeService.mode,
              builder: (context, mode, _) {
                return SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('Sistema'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Claro'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Oscuro'),
                      ),
                    ],
                    selected: {mode},
                    onSelectionChanged: (s) => ThemeService.setMode(s.first),
                  ),
                );
              },
            ),
          ),

          // ---------- Moneda ----------
          header('Moneda'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<AppCurrency>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: AppCurrency.usd,
                    label: Text('Dólares · USD'),
                  ),
                  ButtonSegment(
                    value: AppCurrency.cop,
                    label: Text('Pesos · COP'),
                  ),
                ],
                selected: {currency.currency},
                onSelectionChanged: (s) => currency.setCurrency(s.first),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Row(
                  children: [
                    Icon(Icons.currency_exchange, color: scheme.primary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currency.rateLabel,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currency.rateStatus,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    currency.isRefreshing
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4),
                            ),
                          )
                        : IconButton(
                            tooltip: 'Actualizar tasa',
                            icon: const Icon(Icons.refresh),
                            onPressed: () => _refreshRate(context),
                          ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              'Los precios del simulador están en dólares y se convierten a '
              'pesos con una tasa de referencia del mercado (no es la TRM '
              'oficial). Tasas de cambio: ExchangeRate-API.',
              style: theme.textTheme.bodySmall?.copyWith(color: muted, height: 1.4),
            ),
          ),

          // ---------- Simulador ----------
          header('Simulador'),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text('Reiniciar simulador'),
            subtitle: Text(
              'Vuelve a ${currency.format(kInitialCash)} virtuales y borra tus posiciones.',
            ),
            onTap: () => _confirmReset(context),
          ),

          // ---------- Acerca de ----------
          header('Acerca de'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('InverApp'),
            subtitle: Text('Versión 1.1.1'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Text(
              'InverApp es un repositorio de información financiera con un '
              'simulador de inversión. Usa dinero virtual y precios de ejemplo; '
              'no es asesoría financiera ni permite operar con dinero real.',
              style: theme.textTheme.bodySmall?.copyWith(color: muted, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
