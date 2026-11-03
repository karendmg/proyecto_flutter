import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_flutter/config/router.dart';
import 'package:proyecto_flutter/data/mock_data.dart';
import 'package:proyecto_flutter/models/content_item.dart';
import 'package:proyecto_flutter/services/portfolio_service.dart';
import 'package:proyecto_flutter/widgets/section_title.dart';

/// Pestaña "Invertir".
/// Muestra el efectivo disponible y la lista de activos para comprar.
class InvestTab extends StatelessWidget {
  const InvestTab({super.key});

  @override
  Widget build(BuildContext context) {
    final assets = kAssetItems;

    // Escucha los cambios del portafolio (cuando compras/vendes, la UI se actualiza)
    return ListenableBuilder(
      listenable: PortfolioService.instance,
      builder: (context, _) {
        return Column(
          children: [
            // ---------- TARJETA DE EFECTIVO ----------
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Efectivo disponible'),
                  const SizedBox(height: 6),
                  Text(
                    '\$${PortfolioService.instance.cash.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ---------- TÍTULO ----------
            const SectionTitle(text: 'Activos disponibles'),

            // ---------- LISTA DE ACTIVOS ----------
            Expanded(
              child: ListView.builder(
                itemCount: assets.length,
                itemBuilder: (context, i) => _AssetTile(asset: assets[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widget privado para dibujar UNA fila de activo.
class _AssetTile extends StatelessWidget {
  const _AssetTile({required this.asset});

  final ContentItem asset;

  @override
  Widget build(BuildContext context) {
    final positive = asset.changePercent >= 0;
    final color = positive ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        // Al tocar, navega al detalle del activo
        onTap: () =>
            context.push('${AppRoutes.detail}/${asset.id}', extra: asset),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            asset.title.substring(0, 1), // Primera letra del título
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(asset.title),
        subtitle: Text(asset.category),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Precio
            Text(
              '\$${asset.price.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            // Cambio porcentual (verde si sube, rojo si baja)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  positive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: color,
                ),
                Text(
                  '${asset.changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(color: color, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
