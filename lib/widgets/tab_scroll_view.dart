import 'package:flutter/material.dart';

/// Lista con scroll propia de cada pestaña.
///
/// Las 4 pestañas viven a la vez dentro de un IndexedStack. Si todas usaran el
/// controlador de scroll "primario" de la ruta, Flutter (sobre todo en web y
/// escritorio, por las barras de scroll) se queja de que un mismo controlador
/// está en varios scrolls. Con un controlador propio por pestaña no pasa.
class TabScrollView extends StatefulWidget {
  const TabScrollView({super.key, required this.slivers});

  final List<Widget> slivers;

  @override
  State<TabScrollView> createState() => _TabScrollViewState();
}

class _TabScrollViewState extends State<TabScrollView> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _controller,
      slivers: widget.slivers,
    );
  }
}
