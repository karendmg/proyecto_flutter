import 'package:go_router/go_router.dart';
import 'package:proyecto_flutter/models/content_item.dart';
import 'package:proyecto_flutter/pages/detail_page.dart';
import 'package:proyecto_flutter/pages/home_page.dart';
import 'package:proyecto_flutter/pages/login_page.dart';
import 'package:proyecto_flutter/pages/register_page.dart';
import 'package:proyecto_flutter/pages/settings_page.dart';

/// Nombres de las rutas de la app.
/// Centralizados aquí para evitar errores de tipeo.
class AppRoutes {
  static const login = '/';
  static const register = '/register';
  static const home = '/home';
  static const detail = '/detail';
  static const settings = '/settings';
}

/// Configuración del router de la app.
/// GoRouter se encarga de manejar la navegación declarativamente.
final GoRouter appRouter = GoRouter(
  // Ruta inicial al abrir la app
  initialLocation: AppRoutes.login,

  routes: [
    // ---------- LOGIN ----------
    GoRoute(
      path: AppRoutes.login,
      // Sintaxis actualizada de go_router
      builder: (context, state) => const LoginPage(),
    ),

    // ---------- REGISTRO ----------
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),

    // ---------- HOME (con los 4 tabs) ----------
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),

    // ---------- DETALLE (con ID en la URL) ----------
    GoRoute(
      path: '${AppRoutes.detail}/:id',
      builder: (context, state) {
        // Aquí extraemos el ID y el objeto que viaja en el 'extra'
        final id = state.pathParameters['id']!;
        final extra = state.extra as ContentItem?;
        return DetailPage(id: id, item: extra);
      },
    ),

    // ---------- CONFIGURACIÓN ----------
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
