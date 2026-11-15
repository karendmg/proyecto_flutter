/// Formato de números y fechas en español: 1.234,56
class Fmt {
  Fmt._();

  static const List<String> _months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  /// 1234567.891 -> "1.234.567,89" (sin signo ni símbolo).
  static String number(double value, {int decimals = 2}) {
    if (!value.isFinite) return '—';
    final rounded = double.parse(value.abs().toStringAsFixed(decimals));
    final parts = rounded.toStringAsFixed(decimals).split('.');
    final intPart = parts[0];
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      final remaining = intPart.length - i;
      buffer.write(intPart[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
    }
    if (decimals > 0) {
      buffer.write(',');
      buffer.write(parts[1]);
    }
    return buffer.toString();
  }

  /// 1234.5 -> "$1.234,50"  |  -20 -> "-$20,00"
  static String money(double value, {int decimals = 2}) {
    if (!value.isFinite) return '—';
    final isZero = double.parse(value.abs().toStringAsFixed(decimals)) == 0;
    final negative = value < 0 && !isZero;
    return '${negative ? '-' : ''}\$${number(value, decimals: decimals)}';
  }

  /// 12.5 -> "+$12,50"  |  -3 -> "-$3,00"
  static String signedMoney(double value, {int decimals = 2}) {
    if (!value.isFinite) return '—';
    final isZero = double.parse(value.abs().toStringAsFixed(decimals)) == 0;
    final negative = value < 0 && !isZero;
    return '${negative ? '-' : '+'}\$${number(value, decimals: decimals)}';
  }

  /// 1.236 -> "+1,24%"  |  con signed:false -> "1,24%"
  static String percent(double value, {bool signed = true, int decimals = 2}) {
    if (!value.isFinite) return '—';
    final rounded = double.parse(value.abs().toStringAsFixed(decimals));
    final body = rounded.toStringAsFixed(decimals).replaceAll('.', ',');
    if (!signed) return '$body%';
    final negative = value < 0 && rounded != 0;
    return '${negative ? '-' : '+'}$body%';
  }

  /// "14 nov · 15:05"
  static String dateTime(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_months[d.month - 1]} · $hh:$mm';
  }
}
