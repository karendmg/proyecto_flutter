import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_flutter/config/router.dart';
import 'package:proyecto_flutter/data/mock_data.dart';
import 'package:proyecto_flutter/models/content_item.dart';
import 'package:proyecto_flutter/widgets/section_title.dart';

/// Pestaña "Aprende".
/// Muestra una lista de tarjetas con contenido educativo financiero.
class InfoTab extends StatelessWidget {
  const InfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Traemos solo los elementos de tipo 'info' desde mock_data
    final items = kInfoItems;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      // Sumamos 1 al total porque el primer ítem es el título de sección
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        // El índice 0 siempre es el título
        if (index == 0) {
          return const SectionTitle(text: 'Repositorio de información');
        }
        // Los demás son las tarjetas
        final item = items[index - 1];
        return _InfoCard(item: item);
      },
    );
  }
}

/// Widget privado para dibujar UNA tarjeta de información.
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior:
          Clip.antiAlias, // Recorta la imagen a los bordes redondeados
      child: InkWell(
        // Al tocar, navega a la pantalla de detalle pasando el item
        onTap: () =>
            context.push('${AppRoutes.detail}/${item.id}', extra: item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen superior de la tarjeta
            Image.network(
              item.imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              // Si la imagen falla, muestra un ícono gris
              errorBuilder: (_, __, ___) => Container(
                height: 160,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const Icon(Icons.image_not_supported, size: 40),
              ),
            ),
            // Contenido de la tarjeta
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría en mayúsculas y verde
                  Text(
                    item.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Título principal
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Resumen
                  Text(
                    item.summary,
                    style: Theme.of(context).textTheme.bodyMedium,
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
