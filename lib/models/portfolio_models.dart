import 'package:cloud_firestore/cloud_firestore.dart';

/// Posición del usuario en un activo (documento `users/{uid}/holdings/{assetId}`).
class Holding {
  const Holding({
    required this.assetId,
    required this.title,
    required this.category,
    required this.shares,
    required this.avgPrice,
  });

  final String assetId;
  final String title;
  final String category;
  final int shares;

  /// Precio promedio de compra por unidad.
  final double avgPrice;

  /// Lo que le costó al usuario esta posición.
  double get cost => shares * avgPrice;

  factory Holding.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return Holding(
      assetId: doc.id,
      title: (d['title'] as String?) ?? doc.id,
      category: (d['category'] as String?) ?? '',
      shares: (d['shares'] as num?)?.toInt() ?? 0,
      avgPrice: (d['avgPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

enum TradeSide { buy, sell }

/// Movimiento del historial (documento `users/{uid}/trades/{id}`).
class TradeRecord {
  const TradeRecord({
    required this.id,
    required this.assetId,
    required this.title,
    required this.side,
    required this.shares,
    required this.price,
    required this.total,
    required this.date,
  });

  final String id;
  final String assetId;
  final String title;
  final TradeSide side;
  final int shares;
  final double price;
  final double total;
  final DateTime date;

  /// Efecto en el efectivo: una compra resta, una venta suma.
  double get cashFlow => side == TradeSide.buy ? -total : total;

  factory TradeRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    final ts = d['date'];
    return TradeRecord(
      id: doc.id,
      assetId: (d['assetId'] as String?) ?? '',
      title: (d['title'] as String?) ?? '',
      side: d['side'] == 'sell' ? TradeSide.sell : TradeSide.buy,
      shares: (d['shares'] as num?)?.toInt() ?? 0,
      price: (d['price'] as num?)?.toDouble() ?? 0.0,
      total: (d['total'] as num?)?.toDouble() ?? 0.0,
      // Mientras el servidor no confirma la hora, el campo llega null.
      date: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }
}

/// Resultado de una compra/venta, con un mensaje listo para mostrar.
class TradeResult {
  const TradeResult.success(this.message) : ok = true;
  const TradeResult.failure(this.message) : ok = false;

  final bool ok;
  final String message;
}
