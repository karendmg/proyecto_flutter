import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/content_item.dart';
import '../pages/detail_page.dart';
import '../pages/forgot_password_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/settings_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String settings = '/settings';

  /// Ruta de detalle de un elemento: /detail/a1
  static String detailOf(String id) => '$detail/$id';
}

/// Avisa al router cada vez que cambia la sesión (login / logout) para que
/// vuelva a evaluar las redirecciones.
class AuthRefresh extends ChangeNotifier {
  AuthRefresh() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
}

final authRefresh = AuthRefresh();

final appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  refreshListenable: authRefresh,
  redirect: (context, state) {
    final logged = FirebaseAuth.instance.currentUser != null;
    final loc = state.matchedLocation;
    final goingAuth = loc == AppRoutes.login ||
        loc == AppRoutes.register ||
        loc == AppRoutes.forgotPassword;

    if (!logged && !goingAuth) return AppRoutes.login;
    if (logged && goingAuth) return AppRoutes.home;
    return null;
  },
  errorBuilder: (context, state) => const _NotFoundPage(),
  routes: [
    GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => ForgotPasswordPage(
        initialEmail: state.uri.queryParameters['email'] ?? '',
      ),
    ),
    GoRoute(path: AppRoutes.home, builder: (context, state) => const HomePage()),
    GoRoute(
      path: '${AppRoutes.detail}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final extra = state.extra;
        return DetailPage(id: id, item: extra is ContentItem ? extra : null);
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_off_outlined, size: 56),
            const SizedBox(height: 12),
            const Text('Esta página no existe'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
