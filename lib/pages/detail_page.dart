import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/router.dart';
import '../config/theme.dart';
import '../data/mock_data.dart';
import '../models/content_item.dart';
import '../services/portfolio_service.dart';
import '../services/user_data_service.dart';
import '../widgets/asset_tile.dart';
import '../widgets/change_pill.dart';
import '../widgets/currency_scope.dart';
import '../widgets/item_image.dart';
import '../widgets/price_chart.dart';
import '../widgets/trade_sheet.dart';

/// Detalle de un elemento. Si es información, muestra el artículo y los
/// activos relacionados; si es un activo, muestra precio y botones de
/// compra/venta.
class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.id, this.item});

  /// ID del elemento (viene de la URL).
  final String id;

  /// Objeto completo (viene como `extra` al navegar). Si es null, se busca
  /// por [id]: así también funciona al recargar la página en web.
  final ContentItem? item;

  @override
  Widget build(BuildContext context) {
    final data = item ?? findItemById(id);
    if (data == null) return const _NotFound();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final paragraphs = data.body.split('\n\n');
    final related = [
      for (final rid in data.relatedAssetIds)
        if (findItemById(rid) != null) findItemById(rid)!,
    ];

    return Scaffold(
      bottomNavigationBar: data.isAsset ? _TradeBar(asset: data) : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            leading: const Padding(
              padding: EdgeInsets.all(8),
              child: _RoundBackButton(),
            ),
            actions: [
              if (data.isAsset)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: _FavoriteButton(assetId: data.id),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ItemImage(
                    asset: data.imageAsset,
                    icon: AppIcons.forCategory(data.category),
                  ),
                  // Sombra suave arriba para que la flecha siempre se lea.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [Color(0x66000000), Color(0x00000000)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- Categoría + tiempo de lectura ----------
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w800,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      if (data.isInfo) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${data.readingMinutes} min de lectura',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    data.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ---------- Solo activos: precio y posición ----------
                  if (data.isAsset) ...[
                    _AssetHeader(asset: data),
                    const SizedBox(height: 12),
                    _PositionCard(asset: data),
                    const SizedBox(height: 12),
                    PriceChartCard(asset: data),
                    const SizedBox(height: 20),
                  ],

                  // ---------- Cuerpo ----------
                  for (final p in paragraphs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        p,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
                      ),
                    ),

                  // ---------- Solo información: marcar como leído ----------
                  if (data.isInfo) _ReadButton(articleId: data.id),

                  // ---------- Solo información: pasa a la práctica ----------
                  if (data.isInfo && related.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Ponlo en práctica',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Activos del simulador relacionados con este tema.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListenableBuilder(
                      listenable: PortfolioService.instance,
                      builder: (context, _) => Column(
                        children: [
                          for (final a in related)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: AssetTile(
                                asset: a,
                                owned: PortfolioService.instance.sharesOf(a.id),
                                onTap: () => context.push(
                                  AppRoutes.detailOf(a.id),
                                  extra: a,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],

                  if (data.isAsset) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Simulador educativo con dinero virtual. Los precios son '
                      'de ejemplo y no constituyen asesoría financiera.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón circular semitransparente que se lee bien sobre cualquier imagen.
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: scheme.surface.withValues(alpha: 0.88),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(child: Icon(icon, color: color)),
        ),
      ),
    );
  }
}

/// Flecha de volver sobre la imagen. Si no hay a dónde volver (por ejemplo
/// al recargar la página en web), manda al inicio.
class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton();

  @override
  Widget build(BuildContext context) {
    return _RoundIconButton(
      icon: Icons.arrow_back,
      tooltip: 'Volver',
      onTap: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.home);
        }
      },
    );
  }
}

/// Estrella para guardar o quitar un activo de favoritos.
class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserDataService.instance,
      builder: (context, _) {
        final fav = UserDataService.instance.isFavorite(assetId);
        return _RoundIconButton(
          icon: fav ? Icons.star_rounded : Icons.star_border_rounded,
          color: fav ? const Color(0xFFF59E0B) : null,
          tooltip: fav ? 'Quitar de favoritos' : 'Agregar a favoritos',
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            final ok = await UserDataService.instance.toggleFavorite(assetId);
            if (!ok) {
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo guardar. Revisa tu conexión.'),
                  ),
                );
            }
          },
        );
      },
    );
  }
}

/// Botón para marcar un artículo como leído (alimenta el progreso de Aprende).
class _ReadButton extends StatelessWidget {
  const _ReadButton({required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserDataService.instance,
      builder: (context, _) {
        final isRead = UserDataService.instance.isRead(articleId);
        Future<void> toggle() async {
          final messenger = ScaffoldMessenger.of(context);
          final ok = await UserDataService.instance.setRead(
            articleId,
            !isRead,
          );
          if (!ok) {
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('No se pudo guardar. Revisa tu conexión.'),
                ),
              );
          }
        }

        return SizedBox(
          width: double.infinity,
          child: isRead
              ? OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(64, 50),
                  ),
                  onPressed: toggle,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Leído · toca para desmarcar'),
                )
              : FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size(64, 50)),
                  onPressed: toggle,
                  icon: const Icon(Icons.check),
                  label: const Text('Marcar como leído'),
                ),
        );
      },
    );
  }
}

/// Precio actual y variación del día.
class _AssetHeader extends StatelessWidget {
  const _AssetHeader({required this.asset});

  final ContentItem asset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Precio actual',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                MoneyText(
                  asset.price,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.moneyOther(asset.price),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ChangePill(value: asset.changePercent),
                const SizedBox(height: 4),
                Text(
                  'hoy',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "Tu posición": solo aparece si el usuario ya tiene unidades.
class _PositionCard extends StatelessWidget {
  const _PositionCard({required this.asset});

  final ContentItem asset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: PortfolioService.instance,
      builder: (context, _) {
        final holding = PortfolioService.instance.holdingOf(asset.id);
        if (holding == null || holding.shares == 0) {
          return const SizedBox.shrink();
        }
        final value = asset.price * holding.shares;
        final pnl = value - holding.cost;
        final pnlColor = AppColors.change(context, pnl);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu posición',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        label: 'Unidades',
                        value: '${holding.shares}',
                      ),
                    ),
                    Expanded(
                      child: _Stat(label: 'Valor', value: context.money(value)),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'Ganancia',
                        value: context.money(pnl, signed: true),
                        color: pnlColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Barra fija inferior con Vender / Comprar.
class _TradeBar extends StatelessWidget {
  const _TradeBar({required this.asset});

  final ContentItem asset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: PortfolioService.instance,
      builder: (context, _) {
        final owned = PortfolioService.instance.sharesOf(asset.id);
        return Material(
          color: scheme.surface,
          elevation: 8,
          shadowColor: Colors.black54,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(64, 52),
                      ),
                      onPressed: owned == 0
                          ? null
                          : () => showTradeSheet(
                              context,
                              asset: asset,
                              buy: false,
                            ),
                      icon: const Icon(Icons.sell_outlined),
                      label: const Text('Vender'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(64, 52),
                      ),
                      onPressed: () =>
                          showTradeSheet(context, asset: asset, buy: true),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Comprar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 56),
            const SizedBox(height: 12),
            const Text('Contenido no encontrado'),
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
