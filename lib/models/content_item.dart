/// Tipos de contenido que maneja la app.
enum ContentType { info, asset }

/// Modelo que representa un elemento del repositorio.
/// Puede ser información educativa (info) o un activo de inversión (asset).
class ContentItem {
  final String id;
  final String title;
  final String category;
  final String summary;
  final String body;
  final String imageUrl;
  final ContentType type;
  final double price;
  final double changePercent;

  const ContentItem({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.body,
    required this.imageUrl,
    required this.type,
    this.price = 0,
    this.changePercent = 0,
  });
}
