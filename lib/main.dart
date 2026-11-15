import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/router.dart';
import 'config/scroll_behavior.dart';
import 'config/theme.dart';
import 'firebase_options.dart';
import 'services/currency_service.dart';
import 'services/theme_service.dart';
import 'widgets/currency_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    // Si Firebase no arranca, mostramos el motivo en pantalla en vez de
    // dejar la app en blanco.
    runApp(_StartupError(message: '$e'));
    return;
  }

  // Preferencias guardadas (tema y moneda) antes de dibujar la primera pantalla.
  await Future.wait([ThemeService.load(), CurrencyService.instance.load()]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // CurrencyScope: al cambiar entre USD y COP, todos los montos se redibujan.
    // ValueListenableBuilder: escucha si cambia el tema (claro/oscuro/sistema).
    return CurrencyScope(
      service: CurrencyService.instance,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeService.mode,
        builder: (context, mode, _) {
          return MaterialApp.router(
            title: 'InverApp',
            debugShowCheckedModeBanner: false,
            themeMode: mode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            locale: const Locale('es'),
            supportedLocales: const [Locale('es'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            scrollBehavior: const AppScrollBehavior(),
            routerConfig: appRouter,
            builder: (context, child) =>
                _MaxWidthFrame(child: child ?? const SizedBox.shrink()),
          );
        },
      ),
    );
  }
}

/// En pantallas anchas (web, tablet, escritorio) centra la app en una columna
/// del ancho de un teléfono para que no se vea estirada.
class _MaxWidthFrame extends StatelessWidget {
  const _MaxWidthFrame({required this.child});

  final Widget child;

  static const double _maxWidth = 520;

  @override
  Widget build(BuildContext context) {
    final sides = Theme.of(context).colorScheme.surfaceContainerHighest;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.maxWidth > _maxWidth ? _maxWidth : constraints.maxWidth;
        return ColoredBox(
          color: sides,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width,
              height: constraints.maxHeight,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 56, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'No se pudo iniciar Firebase',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
