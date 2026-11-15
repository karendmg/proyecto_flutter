import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_flutter/config/theme.dart';
import 'package:proyecto_flutter/data/mock_data.dart';
import 'package:proyecto_flutter/models/portfolio_models.dart';
import 'package:proyecto_flutter/services/currency_service.dart';
import 'package:proyecto_flutter/widgets/allocation_card.dart';
import 'package:proyecto_flutter/widgets/app_primary_button.dart';
import 'package:proyecto_flutter/widgets/app_text_field.dart';
import 'package:proyecto_flutter/widgets/asset_tile.dart';
import 'package:proyecto_flutter/widgets/currency_scope.dart';
import 'package:proyecto_flutter/widgets/currency_toggle.dart';
import 'package:proyecto_flutter/widgets/filter_chips_bar.dart';
import 'package:proyecto_flutter/widgets/item_image.dart';

// Pruebas de widgets reutilizables. No inicializan Firebase.

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

/// Fuerza un ancho de 300 (un celular angosto). El Align es necesario: sin él,
/// las restricciones estrictas del Scaffold estirarían el SizedBox.
Widget _narrow(Widget child) {
  return Align(
    alignment: Alignment.topLeft,
    child: SizedBox(width: 300, child: child),
  );
}

void main() {
  testWidgets('AppPrimaryButton llama onPressed al tocarlo', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(AppPrimaryButton(label: 'Entrar', onPressed: () => taps++)),
    );

    await tester.tap(find.text('Entrar'));
    expect(taps, 1);
  });

  testWidgets('AppPrimaryButton cargando muestra spinner y ignora toques', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        AppPrimaryButton(
          label: 'Entrar',
          isLoading: true,
          onPressed: () => taps++,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Entrar'), findsNothing);

    await tester.tap(find.byType(FilledButton));
    expect(taps, 0);
  });

  testWidgets('AppTextField de contraseña alterna mostrar/ocultar', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const AppTextField(label: 'Contraseña', obscureText: true)),
    );

    bool obscured() =>
        tester.widget<EditableText>(find.byType(EditableText)).obscureText;

    expect(obscured(), isTrue);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(obscured(), isFalse);
  });

  testWidgets('AssetTile muestra nombre, precio con moneda, variación y unidades', (
    tester,
  ) async {
    CurrencyService.instance.debugSetRate(3300);
    CurrencyService.instance.setCurrency(AppCurrency.usd);
    final etf = findItemById('i1')!; // ETF S&P 500: 420,50 USD (+1,24%)

    await tester.pumpWidget(
      _wrap(
        CurrencyScope(
          service: CurrencyService.instance,
          child: AssetTile(asset: etf, owned: 3),
        ),
      ),
    );

    expect(find.text('ETF S&P 500'), findsOneWidget);
    expect(find.textContaining('\$420,50', findRichText: true), findsOneWidget);
    expect(find.textContaining('USD', findRichText: true), findsOneWidget);
    expect(find.text('1,24%'), findsOneWidget);
    expect(find.text('Tienes 3 u.'), findsOneWidget);
  });

  testWidgets('Al tocar COP los montos se convierten a pesos', (tester) async {
    CurrencyService.instance.debugSetRate(3300);
    CurrencyService.instance.setCurrency(AppCurrency.usd);
    final etf = findItemById('i1')!;

    await tester.pumpWidget(
      _wrap(
        CurrencyScope(
          service: CurrencyService.instance,
          child: Column(
            children: [
              const CurrencyToggle(),
              AssetTile(asset: etf),
            ],
          ),
        ),
      ),
    );
    expect(find.textContaining('420,50', findRichText: true), findsOneWidget);

    await tester.tap(find.text('COP'));
    await tester.pump();

    // 420,50 USD x 3.300 = 1.387.650 COP
    expect(find.textContaining('1.387.650', findRichText: true), findsOneWidget);
    expect(find.textContaining('COP', findRichText: true), findsWidgets);
  });

  testWidgets('ItemImage muestra la ilustración local del archivo', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 200,
          height: 112,
          child: ItemImage(asset: 'assets/images/learn_interest.png'),
        ),
      ),
    );
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('AllocationCard dibuja la barra con altura real y la leyenda', (
    tester,
  ) async {
    final reit = findItemById('i4')!;
    final etf = findItemById('i1')!;
    // 2 u. x 55,75 = 111,50 invertidos + 9.888,50 en efectivo = 10.000.
    final holdings = [
      const Holding(
        assetId: 'i4',
        title: 'Fondo inmobiliario (REIT)',
        category: 'Bienes raíces',
        shares: 2,
        avgPrice: 55.75,
      ),
    ];

    await tester.pumpWidget(
      _wrap(
        AllocationCard(
          holdings: holdings,
          byId: {reit.id: reit, etf.id: etf},
          cash: 9888.5,
        ),
      ),
    );

    // Regresión: antes los segmentos medían 0 de alto y la barra no se veía.
    for (final i in [0, 1]) {
      final size = tester.getSize(find.byKey(ValueKey('allocation-segment-$i')));
      expect(size.height, AllocationCard.barHeight, reason: 'segmento $i');
      expect(size.width, greaterThan(0), reason: 'segmento $i');
    }
    expect(find.textContaining('Bienes raíces ·'), findsOneWidget);
    expect(find.textContaining('Efectivo ·'), findsOneWidget);
  });

  testWidgets('FilterChipsBar se desplaza y deja elegir un filtro oculto', (
    tester,
  ) async {
    var selected = 'Todos';
    final labels = [
      'Todos',
      'Favoritos',
      'Renta variable',
      'Renta fija',
      'Bienes raíces',
      'Materias primas',
    ];

    await tester.pumpWidget(
      _wrap(
        _narrow(
          StatefulBuilder(
            builder: (context, setState) => FilterChipsBar(
              labels: labels,
              selected: selected,
              onSelected: (value) => setState(() => selected = value),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final last = find.text('Materias primas');
    final before = tester.getTopLeft(last).dx;
    expect(before, greaterThan(300), reason: 'al inicio queda fuera de vista');

    await tester.drag(find.byType(SingleChildScrollView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    final after = tester.getTopLeft(last).dx;
    expect(after, lessThan(before));
    expect(after, lessThan(300), reason: 'ahora debe verse');

    await tester.tap(last);
    await tester.pumpAndSettle();
    expect(selected, 'Materias primas');
  });

  testWidgets(
    'FilterChipsBar muestra flechas en escritorio/web y desplazan la fila',
    (tester) async {
      final labels = [
        'Todos',
        'Favoritos',
        'Renta variable',
        'Renta fija',
        'Bienes raíces',
        'Materias primas',
      ];

      await tester.pumpWidget(
        _wrap(
          _narrow(
            FilterChipsBar(
              labels: labels,
              selected: 'Todos',
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsNothing);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets('FilterChipsBar no muestra flechas en el celular', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _narrow(
          FilterChipsBar(
            labels: const ['Uno', 'Dos', 'Tres', 'Cuatro', 'Cinco', 'Seis', 'Siete'],
            selected: 'Uno',
            onSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.chevron_right), findsNothing);
    expect(find.byIcon(Icons.chevron_left), findsNothing);
  });
}
