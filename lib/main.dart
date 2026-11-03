import 'package:flutter/material.dart';
import 'package:proyecto_flutter/config/router.dart';
import 'package:proyecto_flutter/config/theme.dart';
import 'package:proyecto_flutter/services/theme_service.dart';

void main() {
  // Punto de entrada de la app.
  // Aquí podrías inicializar Firebase, base de datos, etc.
  runApp(const MyApp());
}

/// Widget raíz de la app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder escucha los cambios de tema (claro/oscuro).
    // Cuando el usuario cambia el tema en Configuración, toda la app
    // se reconstruye automáticamente con los colores nuevos.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.mode,
      builder: (context, mode, _) {
        return MaterialApp.router(
          title: 'InverTrack',
          debugShowCheckedModeBanner: false, // Quita la cinta "DEBUG"
          // Configuración del tema claro/oscuro
          themeMode: mode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,

          // Conecta toda la navegación con GoRouter
          routerConfig: appRouter,
        );
      },
    );
  }
}
