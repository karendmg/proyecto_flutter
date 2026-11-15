import 'package:flutter/material.dart';

import '../services/currency_service.dart';

/// Hace que cualquier widget que lea la moneda (con `context.money(...)`,
/// [MoneyText] o [CurrencyScope.of]) se redibuje solo cuando el usuario
/// cambia entre dólares y pesos, o cuando se actualiza la tasa.
class CurrencyScope extends InheritedNotifier<CurrencyService> {
  const CurrencyScope({
    super.key,
    required CurrencyService service,
    required super.child,
  }) : super(notifier: service);

  static CurrencyService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CurrencyScope>();
    return scope?.notifier ?? CurrencyService.instance;
  }
}

extension CurrencyContext on BuildContext {
  /// Monto (en USD) formateado en la moneda elegida: "$4.850.000 COP".
  String money(double usd, {bool signed = false}) =>
      CurrencyScope.of(this).format(usd, signed: signed);

  /// Equivalencia en la otra moneda: "≈ $1.234,50 USD".
  String moneyOther(double usd) => CurrencyScope.of(this).approx(usd);
}

/// Monto con el valor grande y el código de la moneda más pequeño al lado:
/// "$4.850.000" + "COP".
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.usd, {
    super.key,
    this.style,
    this.signed = false,
    this.color,
  });

  /// Monto en dólares (la app convierte a la moneda elegida).
  final double usd;
  final TextStyle? style;
  final bool signed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final service = CurrencyScope.of(context);
    final base = style ?? DefaultTextStyle.of(context).style;
    final fontSize = base.fontSize ?? 14;
    final textColor = color ?? base.color;

    return Text.rich(
      TextSpan(
        text: service.amount(usd, signed: signed),
        style: base.copyWith(color: textColor),
        children: [
          TextSpan(
            text: ' ${service.currency.code}',
            style: TextStyle(
              fontSize: fontSize * 0.58,
              fontWeight: FontWeight.w700,
              color: textColor?.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
