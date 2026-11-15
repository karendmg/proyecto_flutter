import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Fila horizontal de filtros (chips) que se puede desplazar:
///  - arrastrando con el dedo o con el mouse,
///  - con flechas ‹ › (solo en web y escritorio, donde no hay dedo),
///  - y se desvanece en el borde donde todavía hay más opciones.
/// Al elegir un chip se centra solo, para que nunca quede a medio ver.
class FilterChipsBar extends StatefulWidget {
  const FilterChipsBar({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
    this.avatarFor,
  });

  final List<String> labels;
  final String selected;
  final ValueChanged<String> onSelected;

  /// Ícono opcional a la izquierda de un chip (por ejemplo la estrella).
  final Widget? Function(String label)? avatarFor;

  @override
  State<FilterChipsBar> createState() => _FilterChipsBarState();
}

class _FilterChipsBarState extends State<FilterChipsBar> {
  static const double _height = 48;
  static const double _sidePadding = 16;

  final ScrollController _controller = ScrollController();
  final Map<String, GlobalKey> _keys = {};
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  /// Las flechas solo tienen sentido donde se usa mouse.
  bool get _showArrows =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _scheduleEdgeUpdate();
  }

  @override
  void didUpdateWidget(covariant FilterChipsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleEdgeUpdate();
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  /// Al desplazar se actualiza al instante; si el cambio llega en plena fase
  /// de layout (por ejemplo al redimensionar), se deja para después del frame.
  void _onScroll() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      _scheduleEdgeUpdate();
    } else {
      _updateEdges();
    }
  }

  void _scheduleEdgeUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateEdges());
  }

  /// Revisa si todavía hay chips por ver a la izquierda o a la derecha.
  void _updateEdges() {
    if (!mounted || !_controller.hasClients) return;
    final position = _controller.position;
    final left = position.pixels > 4;
    final right = position.pixels < position.maxScrollExtent - 4;
    if (left != _canScrollLeft || right != _canScrollRight) {
      setState(() {
        _canScrollLeft = left;
        _canScrollRight = right;
      });
    }
  }

  void _scrollBy(double direction) {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final target = _controller.offset + direction * position.viewportDimension * 0.6;
    _controller.animateTo(
      target.clamp(0.0, position.maxScrollExtent).toDouble(),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  /// Centra el chip [label] en la fila (sin mover la lista vertical).
  void _centerChip(String label) {
    final chipContext = _keys[label]?.currentContext;
    final barBox = context.findRenderObject();
    final chipBox = chipContext?.findRenderObject();
    if (!_controller.hasClients ||
        barBox is! RenderBox ||
        chipBox is! RenderBox ||
        !chipBox.attached) {
      return;
    }
    final chipLeft = chipBox.localToGlobal(Offset.zero, ancestor: barBox).dx;
    final target =
        _controller.offset +
        chipLeft +
        chipBox.size.width / 2 -
        barBox.size.width / 2;
    _controller.animateTo(
      target.clamp(0.0, _controller.position.maxScrollExtent).toDouble(),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _select(String label) {
    widget.onSelected(label);
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerChip(label));
  }

  @override
  Widget build(BuildContext context) {
    // Cada vez que cambia el ancho disponible (girar el celular, cambiar el
    // tamaño de la ventana) se vuelve a evaluar si hace falta desplazar.
    return LayoutBuilder(
      builder: (context, constraints) {
        _scheduleEdgeUpdate();
        return SizedBox(
          height: _height,
          child: Stack(
            children: [
              ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: _canScrollLeft ? 0.0 : 1.0),
                    Colors.white,
                    Colors.white,
                    Colors.white.withValues(alpha: _canScrollRight ? 0.0 : 1.0),
                  ],
                  stops: const [0.0, 0.07, 0.93, 1.0],
                ).createShader(bounds),
                child: SingleChildScrollView(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
                  child: Row(
                    children: [
                      for (final label in widget.labels)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            key: _keys.putIfAbsent(label, () => GlobalKey()),
                            avatar: widget.avatarFor?.call(label),
                            label: Text(label),
                            selected: label == widget.selected,
                            showCheckmark: false,
                            onSelected: (_) => _select(label),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_showArrows && _canScrollLeft)
                Positioned(
                  left: 4,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _ArrowButton(
                      icon: Icons.chevron_left,
                      tooltip: 'Ver anteriores',
                      onTap: () => _scrollBy(-1),
                    ),
                  ),
                ),
              if (_showArrows && _canScrollRight)
                Positioned(
                  right: 4,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _ArrowButton(
                      icon: Icons.chevron_right,
                      tooltip: 'Ver más',
                      onTap: () => _scrollBy(1),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: scheme.surfaceContainerHighest,
        elevation: 2,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 30,
            height: 30,
            child: Icon(icon, size: 20, color: scheme.onSurface),
          ),
        ),
      ),
    );
  }
}
