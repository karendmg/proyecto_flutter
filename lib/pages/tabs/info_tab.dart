import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/router.dart';
import '../../config/theme.dart';
import '../../data/mock_data.dart';
import '../../models/content_item.dart';
import '../../services/auth_service.dart';
import '../../services/user_data_service.dart';
import '../../widgets/filter_chips_bar.dart';
import '../../widgets/item_image.dart';
import '../../widgets/page_header.dart';
import '../../widgets/tab_scroll_view.dart';

/// Pestaña "Aprende": artículos educativos con su propia ilustración,
/// filtrables por categoría, con progreso de lectura y consejo del día.
class InfoTab extends StatefulWidget {
  const InfoTab({super.key});

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  static const String _all = 'Todos';
  String _category = _all;

  @override
  Widget build(BuildContext context) {
    final all = kInfoItems;
    final categories = [_all, ...{for (final i in all) i.category}];
    final items = _category == _all
        ? all
        : all.where((i) => i.category == _category).toList();

    return ListenableBuilder(
      listenable: Listenable.merge([
        AuthService.instance,
        UserDataService.instance,
      ]),
      builder: (context, _) {
        final user = UserDataService.instance;
        final readCount = all.where((i) => user.isRead(i.id)).length;

        return TabScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PageHeader(
                title: 'Hola, ${AuthService.instance.userName}',
                subtitle: 'Aprende un poco cada día antes de invertir.',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ProgressCard(read: readCount, total: all.length),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _TipCard(tip: dailyTip()),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: FilterChipsBar(
                  labels: categories,
                  selected: _category,
                  onSelected: (c) => setState(() => _category = c),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) => _InfoCard(
                  item: items[index],
                  isRead: user.isRead(items[index].id),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// "Tu progreso: 2 de 7 lecturas".
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.read, required this.total});

  final int read;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = total > 0 && read >= total;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                done ? Icons.emoji_events_outlined : Icons.school_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    done
                        ? '¡Completaste todas las lecturas!'
                        : 'Tu progreso: $read de $total lecturas',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : read / total,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Consejo del día.
class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: scheme.onTertiaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONSEJO DEL DÍA',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                    color: scheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: TextStyle(
                    height: 1.4,
                    color: scheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.item, required this.isRead});

  final ContentItem item;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onSurfaceVariant;

    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.detailOf(item.id), extra: item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ItemImage(
                    asset: item.imageAsset,
                    icon: AppIcons.forCategory(item.category),
                  ),
                  if (isRead)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 15,
                              color: Color(0xFF4ADE80),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Leído',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.5,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w800,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.schedule, size: 14, color: muted),
                      const SizedBox(width: 4),
                      Text(
                        '${item.readingMinutes} min',
                        style: theme.textTheme.bodySmall?.copyWith(color: muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: muted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
