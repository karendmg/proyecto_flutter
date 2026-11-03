import 'package:flutter/material.dart';
import 'package:proyecto_flutter/data/mock_data.dart';
import 'package:proyecto_flutter/services/portfolio_service.dart';

/// Pestaña "Mi portafolio".
/// Muestra el valor total (efectivo + inversiones) y las posiciones abiertas.
class PortfolioTab extends StatelessWidget {
  const PortfolioTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha cambios para actualizar los valores en vivo
    return ListenableBuilder(
      listenable: PortfolioService.instance,
      builder: (context, _) {
        final service = PortfolioService.instance;
        final holdings = service.holdings;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---------- TARJETA DE VALOR TOTAL ----------
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // Degradado con los colores del tema
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Valor total',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${service.totalValue(kAssetItems).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Efectivo: \$${service.cash.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---------- TÍTULO DE POSICIONES ----------
            Text(
              'Mis posiciones',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // ---------- LISTA DE POSICIONES ----------
            // Si no tiene inversiones, muestra un mensaje vacío
            if (holdings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'Aún no tienes inversiones.\nVe a la pestaña "Invertir".',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              // Si tiene, dibuja una tarjeta por cada activo comprado
              ...holdings.entries.map((entry) {
                final asset = kAssetItems.firstWhere((a) => a.id == entry.key);
                final value = asset.price * entry.value;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.trending_up),
                    title: Text(asset.title),
                    subtitle: Text('${entry.value} unidades'),
                    trailing: Text(
                      '\$${value.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}
