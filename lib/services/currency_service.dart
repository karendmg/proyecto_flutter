import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/formatters.dart';

/// Monedas que la app sabe mostrar.
enum AppCurrency {
  usd('USD'),
  cop('COP');

  const AppCurrency(this.code);
  final String code;
}

/// Moneda en la que el usuario ve los montos, y conversión USD <-> COP.
///
/// Internamente TODO (precios, efectivo, posiciones) se guarda en dólares.
/// Este servicio solo decide cómo se MUESTRA: en dólares tal cual, o
/// multiplicado por la tasa del día para verlo en pesos colombianos.
///
/// La tasa se descarga de internet (ExchangeRate-API) y se guarda en el
/// teléfono; si no hay conexión se usa la última guardada o una de respaldo.
class CurrencyService extends ChangeNotifier {
  CurrencyService._();

  static final CurrencyService instance = CurrencyService._();

  /// Pesos por dólar cuando nunca se ha podido descargar una tasa.
  static const double fallbackRate = 3300.0;

  static const String _rateUrl = 'https://open.er-api.com/v6/latest/USD';
  static const Duration _maxAge = Duration(hours: 12);

  AppCurrency _currency = AppCurrency.cop;
  double _rate = fallbackRate;
  DateTime? _rateTime;
  bool _refreshing = false;
  SharedPreferences? _prefs;

  AppCurrency get currency => _currency;

  /// La otra moneda (la que se muestra como equivalencia).
  AppCurrency get other =>
      _currency == AppCurrency.usd ? AppCurrency.cop : AppCurrency.usd;

  /// Pesos colombianos por 1 dólar.
  double get rate => _rate;

  /// Cuándo se obtuvo la tasa (null = es el valor de respaldo).
  DateTime? get rateTime => _rateTime;
  bool get isRefreshing => _refreshing;

  // ---------------- Carga y guardado ----------------

  /// Lee la preferencia y la última tasa guardadas, y refresca la tasa en
  /// segundo plano si ya está vieja.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _prefs = prefs;
      _currency =
          prefs.getString('currency') == 'usd' ? AppCurrency.usd : AppCurrency.cop;
      final savedRate = prefs.getDouble('copPerUsd');
      final savedTime = prefs.getInt('copPerUsdTime');
      if (savedRate != null && savedRate > 0) {
        _rate = savedRate;
        _rateTime = savedTime == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(savedTime);
      }
    } catch (_) {
      // Sin almacenamiento: se usan los valores por defecto.
    }
    notifyListeners();

    final time = _rateTime;
    if (time == null || DateTime.now().difference(time) > _maxAge) {
      unawaited(refreshRate());
    }
  }

  void setCurrency(AppCurrency value) {
    if (value == _currency) return;
    _currency = value;
    notifyListeners();
    unawaited(_prefs?.setString('currency', value.code.toLowerCase()));
  }

  /// Descarga la tasa del día. Devuelve true si se pudo actualizar.
  Future<bool> refreshRate() async {
    if (_refreshing) return false;
    _refreshing = true;
    notifyListeners();

    var ok = false;
    try {
      final res = await http
          .get(Uri.parse(_rateUrl))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rates = data is Map ? data['rates'] : null;
        final cop = rates is Map ? rates['COP'] : null;
        // Validación básica para no guardar un valor absurdo.
        if (cop is num && cop > 1000 && cop < 10000) {
          _rate = cop.toDouble();
          _rateTime = DateTime.now();
          ok = true;
          await _prefs?.setDouble('copPerUsd', _rate);
          await _prefs?.setInt(
            'copPerUsdTime',
            _rateTime!.millisecondsSinceEpoch,
          );
        }
      }
    } catch (_) {
      // Sin internet o servicio caído: se conserva la tasa anterior.
    }

    _refreshing = false;
    notifyListeners();
    return ok;
  }

  // ---------------- Conversión y formato ----------------

  /// Convierte dólares a la moneda [to].
  double convert(double usd, AppCurrency to) =>
      to == AppCurrency.usd ? usd : usd * _rate;

  /// Solo el número con símbolo, sin el código: "$1.234,50" o "$4.850.000".
  String amount(double usd, {AppCurrency? currency, bool signed = false}) {
    final c = currency ?? _currency;
    final value = convert(usd, c);
    if (!value.isFinite) return '—';
    final decimals = c == AppCurrency.cop ? 0 : 2;
    final isZero = double.parse(value.abs().toStringAsFixed(decimals)) == 0;
    final negative = value < 0 && !isZero;
    final sign = negative ? '-' : (signed ? '+' : '');
    return '$sign\$${Fmt.number(value, decimals: decimals)}';
  }

  /// Monto completo con el código de la moneda: "$4.850.000 COP".
  String format(double usd, {AppCurrency? currency, bool signed = false}) {
    final c = currency ?? _currency;
    return '${amount(usd, currency: c, signed: signed)} ${c.code}';
  }

  /// Equivalencia en la otra moneda: "≈ $1.234,50 USD".
  String approx(double usd) => '≈ ${format(usd, currency: other)}';

  /// "1 USD = 3.300,00 COP"
  String get rateLabel => '1 USD = ${Fmt.number(_rate)} COP';

  /// Texto sobre la frescura de la tasa.
  String get rateStatus {
    final time = _rateTime;
    if (time == null) return 'Tasa de referencia (sin conexión)';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Actualizada ahora';
    if (diff.inMinutes < 60) return 'Actualizada hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Actualizada hace ${diff.inHours} h';
    return 'Actualizada hace ${diff.inDays} d';
  }

  /// Solo para pruebas: fija la tasa sin tocar internet.
  @visibleForTesting
  void debugSetRate(double value) {
    _rate = value;
    _rateTime = DateTime.now();
    notifyListeners();
  }
}
