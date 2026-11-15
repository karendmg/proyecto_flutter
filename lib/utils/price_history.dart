import '../models/content_item.dart';

/// Historial de precios SIMULADO de un activo (últimos [days] días + hoy).
///
/// Es determinista: el mismo activo siempre produce la misma curva, y termina
/// exactamente en su precio actual (y con la variación de hoy). Sirve para
/// dar contexto visual mientras no haya una fuente de datos real.
List<double> priceHistory(ContentItem asset, {int days = 30}) {
  if (!asset.isAsset || asset.price <= 0 || days < 2) return const [];

  // Semilla estable a partir del id (generador MINSTD: sin desbordes).
  var seed = 7;
  for (final unit in asset.id.codeUnits) {
    seed = (seed * 31 + unit) % 2147483647;
  }
  if (seed == 0) seed = 1;
  double next() {
    seed = (seed * 48271) % 2147483647;
    return seed / 2147483647;
  }

  final volatility = switch (asset.category) {
    'Renta fija' => 0.002,
    'Bienes raíces' => 0.006,
    'Materias primas' => 0.007,
    'Renta variable' => 0.012,
    _ => 0.01,
  };

  final values = List<double>.filled(days + 1, asset.price);
  // El día anterior es coherente con la variación de hoy.
  values[days - 1] = asset.price / (1 + asset.changePercent / 100);
  for (var i = days - 2; i >= 0; i--) {
    // Ruido con una leve tendencia alcista a lo largo del período.
    final r = (next() - 0.47) * 2 * volatility;
    values[i] = values[i + 1] / (1 + r);
  }
  return values;
}
