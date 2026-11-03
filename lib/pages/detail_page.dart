import 'package:flutter/material.dart';
import 'package:proyecto_flutter/data/mock_data.dart';
import 'package:proyecto_flutter/models/content_item.dart';
import 'package:proyecto_flutter/services/portfolio_service.dart';

/// Pantalla de detalle de un elemento.
/// Se abre al tocar una tarjeta en "Aprende" o un activo en "Invertir".
class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.id, this.item});

  /// ID del elemento (viene de la URL).
  final String id;

  /// Objeto completo (viene como 'extra' al navegar).
  /// Si es null, se busca por ID en mock_data.
  final ContentItem? item;

  @override
  Widget build(BuildContext context) {
    // Usa el item que viene por parámetro, o lo busca por ID
    final data = item ?? findItemById(id);

    // Si no existe el elemento, muestra error
    if (data == null) {
      return const Scaffold(
        body: Center(child: Text('Contenido no encontrado')),
      );
    }

    final isAsset = data.type == ContentType.asset;

    return Scaffold(
      appBar: AppBar(title: Text(data.title)),
      body: ListView(
        children: [
          // ---------- IMAGEN ----------
          Image.network(
            data.imageUrl,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 220,
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: const Icon(Icons.image_not_supported, size: 48),
            ),
          ),

          // ---------- CONTENIDO ----------
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categoría
                Text(
                  data.category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),

                // Título
                Text(
                  data.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Si es un activo, muestra el encabezado con el precio
                if (isAsset) _AssetHeader(asset: data),
                const SizedBox(height: 16),

                // Cuerpo de texto
                Text(
                  data.body,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5, // Interlineado cómodo
                  ),
                ),
                const SizedBox(height: 32),

                // Si es un activo, muestra botones de comprar/vender
                if (isAsset) _BuySection(asset: data),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Encabezado con el precio y el cambio porcentual.
/// Solo aparece en activos.
class _AssetHeader extends StatelessWidget {
  const _AssetHeader({required this.asset});

  final ContentItem asset;

  @override
  Widget build(BuildContext context) {
    final positive = asset.changePercent >= 0;
    final color = positive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Precio actual'),
              const SizedBox(height: 4),
              Text(
                '\$${asset.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                positive ? Icons.arrow_upward : Icons.arrow_downward,
                color: color,
                size: 18,
              ),
              Text(
                '${asset.changePercent.toStringAsFixed(2)}%',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sección de compra/venta.
/// Solo aparece en activos.
class _BuySection extends StatelessWidget {
  const _BuySection({required this.asset});

  final ContentItem asset;

  @override
  Widget build(BuildContext context) {
    // Escucha cambios del portafolio para actualizar el texto
    return ListenableBuilder(
      listenable: PortfolioService.instance,
      builder: (context, _) {
        final owned = PortfolioService.instance.sharesOf(asset.id);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Muestra cuántas unidades tiene el usuario
            if (owned > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('Tienes $owned unidades de este activo.'),
              ),

            // Botón de comprar
            FilledButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Comprar'),
              onPressed: () => _showTradeDialog(context, buy: true),
            ),
            const SizedBox(height: 10),

            // Botón de vender (deshabilitado si no tiene unidades)
            OutlinedButton.icon(
              icon: const Icon(Icons.sell_outlined),
              label: const Text('Vender'),
              onPressed: owned == 0
                  ? null
                  : () => _showTradeDialog(context, buy: false),
            ),
          ],
        );
      },
    );
  }

  /// Muestra un diálogo para elegir la cantidad a comprar o vender.
  void _showTradeDialog(BuildContext context, {required bool buy}) {
    final ctrl = TextEditingController(text: '1');

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(buy ? 'Comprar ${asset.title}' : 'Vender ${asset.title}'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Cantidad',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final qty = int.tryParse(ctrl.text) ?? 0;
                final service = PortfolioService.instance;
                final ok = buy
                    ? service.buy(asset, qty)
                    : service.sell(asset, qty);

                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Operación exitosa'
                          : 'No se pudo completar la operación',
                    ),
                  ),
                );
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
