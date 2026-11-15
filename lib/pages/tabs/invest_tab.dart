import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/router.dart';
import '../../config/theme.dart';
import '../../data/mock_data.dart';
import '../../models/content_item.dart';
import '../../services/portfolio_service.dart';
import '../../services/user_data_service.dart';
import '../../widgets/asset_tile.dart';
import '../../widgets/currency_scope.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chips_bar.dart';
import '../../widgets/page_header.dart';
import '../../widgets/tab_scroll_view.dart';

/// Pestaña "Invertir": catálogo de activos del simulador, con favoritos.
class InvestTab extends StatefulWidget {
  const InvestTab({super.key});

  @override
  State<InvestTab> createState() => _InvestTabState();
}

class _InvestTabState extends State<InvestTab> {
  static const String _all = 'Todos';
  static const String _favorites = 'Favoritos';
  String _category = _all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assets = kAssetItems;
    final categories = [
      _all,
      _favorites,
      ...{for (final a in assets) a.category},
    ];

    return ListenableBuilder(
      listenable: Listenable.merge([
        PortfolioService.instance,
        UserDataService.instance,
      ]),
      builder: (context, _) {
        final portfolio = PortfolioService.instance;
        final user = UserDataService.instance;

        final List<ContentItem> visible;
        if (_category == _all) {
          visible = assets;
        } else if (_category == _favorites) {
          visible = assets.where((a) => user.isFavorite(a.id)).toList();
        } else {
          visible = assets.where((a) => a.category == _category).toList();
        }

        return TabScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: PageHeader(
                title: 'Invertir',
                subtitle:
                    'Elige un activo, compra y mira cómo crece tu portafolio.',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (portfolio.error != null) ...[
                      InfoBanner(
                        message: portfolio.error!,
                        icon: Icons.cloud_off_outlined,
                        isError: true,
                      ),
                      const SizedBox(height: 12),
                    ],
                    _CashCard(cash: portfolio.cash),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: FilterChipsBar(
                  labels: categories,
                  selected: _category,
                  onSelected: (c) => setState(() => _category = c),
                  avatarFor: (label) => label == _favorites
                      ? const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: Color(0xFFF59E0B),
                        )
                      : null,
                ),
              ),
            ),
            if (visible.isEmpty)
              const SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.star_border_rounded,
                  title: 'Aún no tienes favoritos',
                  message:
                      'Abre un activo y toca la estrella para guardarlo aquí.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final asset = visible[index];
                    return AssetTile(
                      asset: asset,
                      owned: portfolio.sharesOf(asset.id),
                      isFavorite: user.isFavorite(asset.id),
                      onTap: () => context.push(
                        AppRoutes.detailOf(asset.id),
                        extra: asset,
                      ),
                    );
                  },
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Text(
                  'InverApp es un simulador educativo con dinero virtual. Los '
                  'precios son de ejemplo y nada de lo que ves aquí constituye '
                  'asesoría financiera.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Tarjeta con el efectivo disponible (y su equivalencia en la otra moneda).
class _CashCard extends StatelessWidget {
  const _CashCard({required this.cash});

  final double cash;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Efectivo disponible',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: MoneyText(
                    cash,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.moneyOther(cash),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
