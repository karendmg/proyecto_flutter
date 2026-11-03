import 'package:flutter/material.dart';
import 'package:proyecto_flutter/pages/tabs/info_tab.dart';
import 'package:proyecto_flutter/pages/tabs/invest_tab.dart';
import 'package:proyecto_flutter/pages/tabs/portfolio_tab.dart';
import 'package:proyecto_flutter/pages/tabs/profile_tab.dart';

/// Pantalla principal después del login.
/// Contiene la barra de navegación inferior con los 4 tabs.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Índice del tab actual (0 = Aprende, 1 = Invertir, 2 = Portafolio, 3 = Perfil)
  int _index = 0;

  // Títulos que se muestran en el AppBar según el tab
  static const _titles = ['Aprende', 'Invertir', 'Mi portafolio', 'Mi perfil'];

  // Los 4 tabs (creados como const para mejor rendimiento)
  final _pages = const [InfoTab(), InvestTab(), PortfolioTab(), ProfileTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index]), centerTitle: false),

      // IndexedStack mantiene los 4 tabs vivos en memoria
      // y solo muestra el que corresponde. Así no se pierde el scroll
      // ni el estado al cambiar de tab.
      body: IndexedStack(index: _index, children: _pages),

      // Barra inferior de navegación
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Aprende',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
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
