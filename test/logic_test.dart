import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_flutter/data/mock_data.dart';
import 'package:proyecto_flutter/models/content_item.dart';
import 'package:proyecto_flutter/services/currency_service.dart';
import 'package:proyecto_flutter/utils/formatters.dart';
import 'package:proyecto_flutter/utils/price_history.dart';
import 'package:proyecto_flutter/utils/validators.dart';

void main() {
  group('Fmt', () {
    test('number usa punto de miles y coma decimal', () {
      expect(Fmt.number(1234567.891), '1.234.567,89');
      expect(Fmt.number(999.999), '1.000,00');
      expect(Fmt.number(12), '12,00');
    });

    test('money agrega símbolo y signo', () {
      expect(Fmt.money(1234.5), '\$1.234,50');
      expect(Fmt.money(-20), '-\$20,00');
      expect(Fmt.money(0, decimals: 0), '\$0');
      expect(Fmt.money(-0.001), '\$0,00'); // sin "-0,00"
    });

    test('signedMoney siempre muestra el signo', () {
      expect(Fmt.signedMoney(12.5), '+\$12,50');
      expect(Fmt.signedMoney(-3), '-\$3,00');
    });

    test('percent', () {
      expect(Fmt.percent(1.236), '+1,24%');
      expect(Fmt.percent(-2.35), '-2,35%');
      expect(Fmt.percent(-2.35, signed: false), '2,35%');
    });

    test('valores no finitos no rompen la pantalla', () {
      expect(Fmt.number(double.nan), '—');
      expect(Fmt.money(double.infinity), '—');
      expect(Fmt.percent(double.nan), '—');
    });

    test('dateTime', () {
      expect(Fmt.dateTime(DateTime(2026, 11, 14, 9, 5)), '14 nov · 09:05');
    });
  });

  group('Validators', () {
    test('email', () {
      expect(Validators.email('persona@correo.com'), isNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('sin-arroba'), isNotNull);
    });

    test('password exige mínimo 6 caracteres', () {
      expect(Validators.password('123456'), isNull);
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password(''), isNotNull);
    });

    test('confirmPassword', () {
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
      expect(Validators.confirmPassword('abc123', 'otra'), isNotNull);
      expect(Validators.confirmPassword('', 'abc123'), isNotNull);
    });

    test('name', () {
      expect(Validators.name('Ana'), isNull);
      expect(Validators.name('  '), isNotNull);
    });
  });

  group('Datos de ejemplo', () {
    test('los ids son únicos', () {
      final ids = kItems.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('los activos tienen precio y la info no', () {
      for (final a in kAssetItems) {
        expect(a.price, greaterThan(0), reason: a.id);
      }
      expect(kAssetItems.every((e) => e.isAsset), isTrue);
      expect(kInfoItems.every((e) => e.isInfo), isTrue);
    });

    test('los activos relacionados existen y son activos', () {
      for (final info in kInfoItems) {
        for (final id in info.relatedAssetIds) {
          final related = findItemById(id);
          expect(related, isNotNull, reason: '${info.id} -> $id');
          expect(related!.type, ContentType.asset, reason: '${info.id} -> $id');
        }
      }
    });

    test('findItemById devuelve null si no existe', () {
      expect(findItemById('no-existe'), isNull);
      expect(findItemById('i1')?.title, 'ETF S&P 500');
    });

    test('cada elemento tiene su propia imagen y el archivo existe', () {
      final paths = kItems.map((e) => e.imageAsset).toList();
      expect(paths.toSet().length, paths.length, reason: 'imágenes repetidas');
      for (final item in kItems) {
        expect(
          File(item.imageAsset).existsSync(),
          isTrue,
          reason: 'falta ${item.imageAsset} (${item.id})',
        );
      }
    });

    test('dailyTip cambia con el día y siempre devuelve un consejo', () {
      final a = dailyTip(DateTime(2026, 11, 14));
      final b = dailyTip(DateTime(2026, 11, 15));
      expect(kDailyTips, contains(a));
      expect(a, isNot(b));
    });

    test('readingMinutes es al menos 1', () {
      for (final item in kItems) {
        expect(item.readingMinutes, greaterThanOrEqualTo(1));
      }
    });
  });

  group('CurrencyService', () {
    final service = CurrencyService.instance;

    setUp(() {
      service.debugSetRate(3300);
      service.setCurrency(AppCurrency.usd);
    });

    test('dólares: dos decimales y código', () {
      expect(service.format(1234.5), '\$1.234,50 USD');
      expect(service.format(-20), '-\$20,00 USD');
      expect(service.format(12.5, signed: true), '+\$12,50 USD');
    });

    test('pesos: convierte con la tasa, sin decimales y con código', () {
      expect(service.format(10, currency: AppCurrency.cop), '\$33.000 COP');
      expect(service.format(1.5, currency: AppCurrency.cop), '\$4.950 COP');
      expect(
        service.format(-2, currency: AppCurrency.cop, signed: true),
        '-\$6.600 COP',
      );
    });

    test('cambiar de moneda cambia el formato por defecto y la equivalencia', () {
      expect(service.format(2), '\$2,00 USD');
      expect(service.approx(2), '≈ \$6.600 COP');
      service.setCurrency(AppCurrency.cop);
      expect(service.format(2), '\$6.600 COP');
      expect(service.approx(2), '≈ \$2,00 USD');
      expect(service.other, AppCurrency.usd);
    });

    test('convert es consistente con la tasa', () {
      expect(service.convert(100, AppCurrency.cop), 330000);
      expect(service.convert(100, AppCurrency.usd), 100);
      expect(service.rateLabel, '1 USD = 3.300,00 COP');
    });
  });

  group('priceHistory', () {
    final etf = findItemById('i1')!;

    test('termina en el precio actual y respeta la variación de hoy', () {
      final h = priceHistory(etf);
      expect(h.length, 31);
      expect(h.last, etf.price);
      final yesterday = etf.price / (1 + etf.changePercent / 100);
      expect(h[h.length - 2], closeTo(yesterday, 1e-9));
    });

    test('es determinista y positivo para todos los activos', () {
      for (final a in kAssetItems) {
        final h1 = priceHistory(a);
        final h2 = priceHistory(a);
        expect(h1, h2, reason: a.id);
        expect(h1.every((v) => v > 0 && v.isFinite), isTrue, reason: a.id);
      }
    });

    test('los artículos no tienen historial', () {
      expect(priceHistory(kInfoItems.first), isEmpty);
    });
  });
}
