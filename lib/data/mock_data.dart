import 'package:proyecto_flutter/models/content_item.dart';

/// Datos de ejemplo que alimentan la app.
/// Cuando conectemos el backend real, este archivo se reemplaza por
/// llamadas HTTP a una API.
const List<ContentItem> kItems = [
  // ---------- CONTENIDO INFORMATIVO ----------
  ContentItem(
    id: 'a1',
    title: '¿Qué es el interés compuesto?',
    category: 'Fundamentos',
    summary: 'El motor silencioso de la riqueza a largo plazo.',
    body:
        'El interés compuesto es el proceso por el cual los intereses que genera '
        'una inversión se reinvierten y, a su vez, producen nuevos intereses.\n\n'
        'Ejemplo: si inviertes \$1.000.000 al 10% anual y reinviertes las ganancias, '
        'en 10 años tendrás aproximadamente \$2.593.742. Sin reinvertir, solo \$2.000.000.\n\n'
        'La clave está en el tiempo: cuanto antes empieces, mayor es el efecto.',
    imageUrl: 'https://picsum.photos/seed/interes/600/400',
    type: ContentType.info,
  ),
  ContentItem(
    id: 'a2',
    title: 'Diversificación: no pongas todos los huevos en una canasta',
    category: 'Estrategia',
    summary: 'Reparte el riesgo entre distintos tipos de activos.',
    body:
        'Diversificar significa distribuir tu dinero en activos que no se muevan '
        'igual al mismo tiempo: acciones, bonos, bienes raíces, CDTs.\n\n'
        'Si un sector cae, otro puede sostener el portafolio. La idea no es eliminar '
        'el riesgo, sino administrarlo.',
    imageUrl: 'https://picsum.photos/seed/diversifica/600/400',
    type: ContentType.info,
  ),
  ContentItem(
    id: 'a3',
    title: 'Perfil de riesgo del inversionista',
    category: 'Fundamentos',
    summary: 'Conservador, moderado o agresivo: ¿cuál eres tú?',
    body:
        'Tu perfil de riesgo depende de tres factores: horizonte de tiempo, '
        'tolerancia a la volatilidad y objetivos financieros.\n\n'
        '• Conservador: prioriza preservar el capital.\n'
        '• Moderado: acepta cierta volatilidad por crecimiento.\n'
        '• Agresivo: busca rentabilidad alta asumiendo caídas fuertes.',
    imageUrl: 'https://picsum.photos/seed/riesgo/600/400',
    type: ContentType.info,
  ),
  ContentItem(
    id: 'a4',
    title: 'Fondo de emergencia antes de invertir',
    category: 'Finanzas personales',
    summary: '3 a 6 meses de gastos guardados antes de arriesgar.',
    body:
        'Antes de invertir necesitas un colchón que cubra entre 3 y 6 meses de '
        'gastos básicos. Ese dinero debe estar en un instrumento líquido y de bajo '
        'riesgo, no en acciones.\n\n'
        'Sin fondo de emergencia, cualquier imprevisto te obliga a vender tus '
        'inversiones en el peor momento.',
    imageUrl: 'https://picsum.photos/seed/emergencia/600/400',
    type: ContentType.info,
  ),

  // ---------- ACTIVOS DE INVERSIÓN ----------
  ContentItem(
    id: 'i1',
    title: 'ETF S&P 500',
    category: 'Renta variable',
    summary: 'Las 500 empresas más grandes de Estados Unidos.',
    body:
        'Un ETF que replica el índice S&P 500. Baja comisión, alta liquidez y '
        'exposición amplia al mercado estadounidense.\n\n'
        'Históricamente ha entregado retornos anuales cercanos al 10% en promedios '
        'de 10 años o más, con volatilidad importante en el corto plazo.',
    imageUrl: 'https://picsum.photos/seed/etf/600/400',
    type: ContentType.asset,
    price: 420.50,
    changePercent: 1.24,
  ),
  ContentItem(
    id: 'i2',
    title: 'Bono soberano TES',
    category: 'Renta fija',
    summary: 'Deuda del gobierno colombiano con rendimiento fijo.',
    body:
        'Los TES son títulos de deuda pública. Ofrecen un rendimiento conocido '
        'de antemano y son considerados de bajo riesgo dentro del mercado local.\n\n'
        'Ideales para perfiles conservadores que buscan flujo de caja.',
    imageUrl: 'https://picsum.photos/seed/bono/600/400',
    type: ContentType.asset,
    price: 102.30,
    changePercent: 0.12,
  ),
  ContentItem(
    id: 'i3',
    title: 'Acciones tecnológicas',
    category: 'Renta variable',
    summary: 'Canasta de las principales empresas de tecnología.',
    body:
        'Exposición a compañías de software, semiconductores y servicios cloud. '
        'Alta volatilidad y alto potencial de crecimiento.\n\n'
        'Recomendado solo para perfiles agresivos con horizonte largo.',
    imageUrl: 'https://picsum.photos/seed/tech/600/400',
    type: ContentType.asset,
    price: 780.00,
    changePercent: -2.35,
  ),
  ContentItem(
    id: 'i4',
    title: 'Fondo inmobiliario (REIT)',
    category: 'Bienes raíces',
    summary: 'Invierte en inmuebles sin comprar uno.',
    body:
        'Un REIT agrupa propiedades y reparte las rentas entre sus inversionistas. '
        'Suele entregar dividendos periódicos y sirve como cobertura contra la '
        'inflación.',
    imageUrl: 'https://picsum.photos/seed/reit/600/400',
    type: ContentType.asset,
    price: 55.75,
    changePercent: 0.86,
  ),
  ContentItem(
    id: 'i5',
    title: 'Oro (commodity)',
    category: 'Materias primas',
    summary: 'Activo refugio clásico ante la incertidumbre.',
    body:
        'El oro tiende a subir cuando hay incertidumbre económica o inflación '
        'alta. Se usa como seguro dentro de un portafolio diversificado.',
    imageUrl: 'https://picsum.photos/seed/gold/600/400',
    type: ContentType.asset,
    price: 1980.40,
    changePercent: 0.45,
  ),
];

/// Solo los elementos informativos.
List<ContentItem> get kInfoItems =>
    kItems.where((e) => e.type == ContentType.info).toList();

/// Solo los activos de inversión.
List<ContentItem> get kAssetItems =>
    kItems.where((e) => e.type == ContentType.asset).toList();

/// Busca un elemento por su id. Devuelve null si no existe.
ContentItem? findItemById(String id) {
  for (final item in kItems) {
    if (item.id == id) return item;
  }
  return null;
}
