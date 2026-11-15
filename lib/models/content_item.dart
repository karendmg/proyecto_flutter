/// Tipos de contenido que maneja la app.
enum ContentType { info, asset }

/// Elemento del repositorio.
/// Puede ser información educativa ([ContentType.info]) o un activo de
/// inversión ([ContentType.asset]) que se puede comprar y vender.
class ContentItem {
  const ContentItem({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.body,
    required this.imageAsset,
    required this.type,
    this.price = 0,
    this.changePercent = 0,
    this.relatedAssetIds = const [],
  });

  final String id;
  final String title;
  final String category;
  final String summary;
  final String body;

  /// Ruta de la ilustración dentro de `assets/images/` (cada elemento tiene
  /// la suya y funciona sin internet).
  final String imageAsset;
  final ContentType type;

  /// Precio por unidad en dólares (USD). Solo activos.
  final double price;

  /// Variación del día en % (solo activos).
  final double changePercent;

  /// Ids de activos relacionados: conecta la información con la inversión.
  final List<String> relatedAssetIds;

  bool get isAsset => type == ContentType.asset;
  bool get isInfo => type == ContentType.info;

  /// Tiempo de lectura estimado (180 palabras por minuto, mínimo 1).
  int get readingMinutes {
    final words = body.trim().split(RegExp(r'\s+')).length;
    final minutes = (words / 180).ceil();
    return minutes < 1 ? 1 : minutes;
  }
}
