import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/content_item.dart';
import '../services/portfolio_service.dart';
import '../services/currency_service.dart';
import 'app_primary_button.dart';
import 'currency_scope.dart';

/// Abre la hoja inferior para comprar o vender [asset].
Future<void> showTradeSheet(
  BuildContext context, {
  required ContentItem asset,
  required bool buy,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _TradeSheet(asset: asset, buy: buy),
  );
}

class _TradeSheet extends StatefulWidget {
  const _TradeSheet({required this.asset, required this.buy});

  final ContentItem asset;
  final bool buy;

  @override
  State<_TradeSheet> createState() => _TradeSheetState();
}

class _TradeSheetState extends State<_TradeSheet> {
  final TextEditingController _ctrl = TextEditingController(text: '1');
  bool _busy = false;
  String? _serverError;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int get _qty => int.tryParse(_ctrl.text) ?? 0;

  void _setQty(int value) {
    final q = value < 0 ? 0 : value;
    setState(() {
      _serverError = null;
      _ctrl.text = '$q';
      _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
    });
  }

  /// Devuelve un mensaje si la cantidad actual no se puede operar.
  String? _validate(PortfolioService p) {
    final q = _qty;
    if (q <= 0) return 'Ingresa una cantidad mayor a cero.';
    if (widget.buy) {
      final cost = widget.asset.price * q;
      if (cost > p.cash + 0.005) {
        return 'Efectivo insuficiente. Te faltan '
            '${CurrencyService.instance.format(cost - p.cash)}.';
      }
    } else {
      final owned = p.sharesOf(widget.asset.id);
      if (q > owned) return 'Solo tienes $owned unidades.';
    }
    return null;
  }

  Future<void> _confirm() async {
    final service = PortfolioService.instance;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final qty = _qty;

    setState(() {
      _busy = true;
      _serverError = null;
    });

    final result = widget.buy
        ? await service.buy(widget.asset, qty)
        : await service.sell(widget.asset, qty);

    if (!mounted) {
      // La hoja se cerró mientras se procesaba: igual avisamos el resultado.
      messenger.showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }

    if (result.ok) {
      navigator.pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.message)));
    } else {
      setState(() {
        _busy = false;
        _serverError = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final asset = widget.asset;
    final verb = widget.buy ? 'Comprar' : 'Vender';

    return ListenableBuilder(
      listenable: PortfolioService.instance,
      builder: (context, _) {
        final p = PortfolioService.instance;
        final qty = _qty;
        final total = asset.price * qty;
        final owned = p.sharesOf(asset.id);
        final error = _serverError ?? _validate(p);

        final maxQty = widget.buy
            ? (asset.price > 0 ? (p.cash / asset.price).floor() : 0)
            : owned;

        return Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + inset),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '$verb ${asset.title}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Precio por unidad: ${context.money(asset.price)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),

                // ---------- Selector de cantidad ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Menos',
                      onPressed: qty > 1 ? () => _setQty(qty - 1) : null,
                      icon: const Icon(Icons.remove),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 110,
                      child: TextField(
                        controller: _ctrl,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onChanged: (_) => setState(() => _serverError = null),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      tooltip: 'Más',
                      onPressed: qty < 999999 ? () => _setQty(qty + 1) : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: ActionChip(
                    label: Text(
                      widget.buy
                          ? 'Máximo ($maxQty)'
                          : 'Vender todo ($maxQty)',
                    ),
                    onPressed: maxQty > 0 ? () => _setQty(maxQty) : null,
                  ),
                ),
                const SizedBox(height: 16),

                // ---------- Resumen ----------
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: widget.buy ? 'Costo total' : 'Recibirás',
                        value: context.money(total),
                        bold: true,
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          context.moneyOther(total),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: 'Efectivo disponible',
                        value: context.money(p.cash),
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: 'Efectivo después',
                        value: context.money(
                          widget.buy ? p.cash - total : p.cash + total,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: 'Unidades que tienes',
                        value: '$owned',
                      ),
                    ],
                  ),
                ),

                if (error != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: scheme.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(color: scheme.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                AppPrimaryButton(
                  label: widget.buy ? 'Confirmar compra' : 'Confirmar venta',
                  isLoading: _busy,
                  onPressed: error == null ? _confirm : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: (bold ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium)
              ?.copyWith(fontWeight: bold ? FontWeight.w800 : FontWeight.w600),
        ),
      ],
    );
  }
}
