import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/router.dart';
import '../../config/theme.dart';
import '../../data/mock_data.dart';
import '../../models/content_item.dart';
import '../../models/portfolio_models.dart';
import '../../services/portfolio_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/allocation_card.dart';
import '../../widgets/asset_tile.dart';
import '../../widgets/currency_scope.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/section_title.dart';
import '../../widgets/tab_scroll_view.dart';

/// Pestaña "Portafolio": valor total, ganancia, distribución, posiciones e
/// historial de movimientos. Todo viene de Firestore en tiempo real.
class PortfolioTab extends StatelessWidget {
  const PortfolioTab({super.key, required this.onExplore});

  /// Se llama desde el estado vacío para llevar al usuario a "Invertir".
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PortfolioService.instance,
      builder: (context, _) {
        final p = PortfolioService.instance;
        final assets = kAssetItems;
        final byId = {for (final a in assets) a.id: a};
        final holdings = p.holdings;
        final trades = p.trades.take(10).toList();
        const heading = EdgeInsets.fromLTRB(4, 24, 4, 10);

        return TabScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: PageHeader(
                title: 'Portafolio',
                subtitle: 'Así van tus inversiones.',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (p.error != null) ...[
                    InfoBanner(
                      message: p.error!,
                      icon: Icons.cloud_off_outlined,
                      isError: true,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _SummaryCard(
                    total: p.totalValue(assets),
                    cash: p.cash,
                    invested: p.investedValue(assets),
                    profit: p.profit(assets),
                    profitPercent: p.profitPercent(assets),
                    hasPositions: holdings.isNotEmpty,
                  ),
                  if (p.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (holdings.isEmpty)
                    EmptyState(
                      icon: Icons.pie_chart_outline,
                      title: 'Aún no tienes inversiones',
                      message:
                          'Empieza con tu efectivo virtual: elige un activo y '
                          'haz tu primera compra.',
                      actionLabel: 'Explorar activos',
                      onAction: onExplore,
                    )
                  else ...[
                    const SectionTitle(text: 'Distribución', padding: heading),
                    AllocationCard(
                      holdings: holdings,
                      byId: byId,
                      cash: p.cash,
                    ),
                    const SectionTitle(
                      text: 'Mis posiciones',
                      padding: heading,
                    ),
                    for (final h in holdings) ...[
                      _HoldingTile(
                        holding: h,
                        asset: byId[h.assetId],
                        onTap: byId[h.assetId] == null
                            ? null
                            : () => context.push(
                                AppRoutes.detailOf(h.assetId),
                                extra: byId[h.assetId],
                              ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                  if (trades.isNotEmpty) ...[
                    const SectionTitle(
                      text: 'Últimos movimientos',
                      padding: heading,
                    ),
                    _TradesCard(trades: trades),
                  ],
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Resumen
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.cash,
    required this.invested,
    required this.profit,
    required this.profitPercent,
    required this.hasPositions,
  });

  final double total;
  final double cash;
  final double invested;
  final double profit;
  final double profitPercent;
  final bool hasPositions;

  @override
  Widget build(BuildContext context) {
    final up = profit >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valor total del portafolio',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: MoneyText(
              total,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.moneyOther(total),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
            ),
          ),
          if (hasPositions) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    up ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${context.money(profit, signed: true)}  (${Fmt.percent(profitPercent)})',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _MiniStat(label: 'Efectivo', value: cash)),
              Expanded(child: _MiniStat(label: 'Invertido', value: invested)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: MoneyText(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Posiciones
// ---------------------------------------------------------------------------

class _HoldingTile extends StatelessWidget {
  const _HoldingTile({required this.holding, required this.asset, this.onTap});

  final Holding holding;

  /// Activo del catálogo (null si ya no existe: se usa el precio de compra).
  final ContentItem? asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    final price = asset?.price ?? holding.avgPrice;
    final value = price * holding.shares;
    final pnl = value - holding.cost;
    final pnlPct = holding.cost == 0 ? 0.0 : pnl / holding.cost * 100;
    final pnlColor = AppColors.change(context, pnl);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CategoryBadge(category: asset?.category ?? holding.category),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holding.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${holding.shares} u. · prom. ${context.money(holding.avgPrice)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyText(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${context.money(pnl, signed: true)} (${Fmt.percent(pnlPct)})',
                    style: TextStyle(
                      color: pnlColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Historial
// ---------------------------------------------------------------------------

class _TradesCard extends StatelessWidget {
  const _TradesCard({required this.trades});

  final List<TradeRecord> trades;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Card(
      child: Column(
        children: [
          for (var i = 0; i < trades.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            _TradeRow(trade: trades[i], muted: muted),
          ],
        ],
      ),
    );
  }
}

class _TradeRow extends StatelessWidget {
  const _TradeRow({required this.trade, required this.muted});

  final TradeRecord trade;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBuy = trade.side == TradeSide.buy;
    final flow = trade.cashFlow;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            isBuy ? Icons.add_circle_outline : Icons.remove_circle_outline,
            color: isBuy
                ? theme.colorScheme.primary
                : AppColors.loss(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isBuy ? 'Compra' : 'Venta'} · ${trade.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${trade.shares} u. × ${context.money(trade.price)} · '
                  '${Fmt.dateTime(trade.date)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            context.money(flow, signed: true),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
