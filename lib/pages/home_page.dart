import 'package:flutter/material.dart';

import '../widgets/brand_logo.dart';
import '../widgets/currency_toggle.dart';
import 'tabs/info_tab.dart';
import 'tabs/invest_tab.dart';
import 'tabs/portfolio_tab.dart';
import 'tabs/profile_tab.dart';

/// Pantalla principal: barra superior con la marca y el selector de moneda,
/// y barra de navegación inferior con 4 pestañas. El perfil se abre solo
/// desde la pestaña "Perfil" (un único punto de acceso).
/// Usa un IndexedStack para que cada pestaña conserve su estado (scroll,
/// filtros) al cambiar de una a otra.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const BrandLogo(size: 34),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'InverApp',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
        actions: const [CurrencyToggle(), SizedBox(width: 16)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: [
          const InfoTab(),
          const InvestTab(),
          PortfolioTab(onExplore: () => _select(1)),
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Aprende',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Invertir',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Portafolio',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
