import 'package:flutter/foundation.dart';
import 'package:proyecto_flutter/models/content_item.dart';

/// Servicio que maneja el portafolio del usuario:
/// cuántas unidades tiene de cada activo y cuánto efectivo le queda.
///
/// Al igual que AuthService, es un singleton ([instance]) y un
/// [ChangeNotifier] para que los widgets se actualicen en vivo
/// cuando el usuario compra o vende.
class PortfolioService extends ChangeNotifier {
  PortfolioService._();
  static final PortfolioService instance = PortfolioService._();

  /// Cuántas unidades tiene el usuario de cada activo.
  /// La clave es el `id` del activo, el valor son las unidades.
  final Map<String, int> _holdings = {};

  /// Efectivo disponible para invertir. Empieza con $10.000.
  double _cash = 10000.0;

  // ---------------- Getters ----------------

  Map<String, int> get holdings => Map.unmodifiable(_holdings);

  double get cash => _cash;

  /// Cuántas unidades tiene el usuario de un activo específico.
  int sharesOf(String id) => _holdings[id] ?? 0;

  /// Calcula el valor total invertido (en unidades * precio actual).
  double investedValue(List<ContentItem> assets) {
    double total = 0;
    _holdings.forEach((id, shares) {
      final asset = assets.firstWhere((a) => a.id == id);
      total += asset.price * shares;
    });
    return total;
  }

  /// Valor total del portafolio: efectivo + invertido.
  double totalValue(List<ContentItem> assets) => _cash + investedValue(assets);

  // ---------------- Acciones ----------------

  /// Intenta comprar [shares] unidades del [asset].
  /// Devuelve true si tuvo éxito, false si no hay efectivo suficiente.
  bool buy(ContentItem asset, int shares) {
    if (shares <= 0) return false;

    final cost = asset.price * shares;
    if (cost > _cash) return false;

    _cash -= cost;
    _holdings[asset.id] = (_holdings[asset.id] ?? 0) + shares;

    notifyListeners();
    return true;
  }

  /// Intenta vender [shares] unidades del [asset].
  /// Devuelve true si tuvo éxito, false si no tiene suficientes unidades.
  bool sell(ContentItem asset, int shares) {
    final current = _holdings[asset.id] ?? 0;
    if (shares <= 0 || shares > current) return false;

    _cash += asset.price * shares;

    final left = current - shares;
    if (left == 0) {
      _holdings.remove(asset.id);
    } else {
      _holdings[asset.id] = left;
    }

    notifyListeners();
    return true;
  }
}
