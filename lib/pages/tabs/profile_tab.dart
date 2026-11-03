import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_flutter/config/router.dart';
import 'package:proyecto_flutter/data/mock_data.dart';
import 'package:proyecto_flutter/services/auth_service.dart';
import 'package:proyecto_flutter/services/portfolio_service.dart';

/// Pestaña "Mi perfil".
/// Muestra los datos del usuario, sus finanzas y opciones de la cuenta.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios de autenticación (ej. cuando cierra sesión)
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) {
        final auth = AuthService.instance;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 12),

            // ---------- AVATAR ----------
            Center(
              child: CircleAvatar(
                radius: 46,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  // Toma la primera letra del nombre y la pone en mayúscula
                  auth.userName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ---------- NOMBRE Y CORREO ----------
            Center(
              child: Text(
                auth.userName,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Center(child: Text(auth.userEmail)),
            const SizedBox(height: 24),

            // ---------- TARJETAS DE RESUMEN ----------
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: const Text('Efectivo'),
                trailing: Text(
                  '\$${PortfolioService.instance.cash.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.pie_chart_outline),
                title: const Text('Valor invertido'),
                trailing: Text(
                  '\$${PortfolioService.instance.investedValue(kAssetItems).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ---------- OPCIONES ----------
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Configuración'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.settings),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                // 1. Limpiamos el estado de autenticación
                AuthService.instance.logout();
                // 2. Regresamos a la pantalla de login
                context.go(AppRoutes.login);
              },
            ),
          ],
        );
      },
    );
  }
}
