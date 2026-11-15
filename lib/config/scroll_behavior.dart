import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Por defecto Flutter solo deja desplazar arrastrando con el dedo (touch).
/// Con esto también se puede arrastrar con el mouse y el trackpad, que es lo
/// que se usa al probar la app en Chrome o en escritorio.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.unknown,
  };
}
