import 'package:proyecto_flutter/models/content_item.dart';

/// Datos de ejemplo que alimentan la app.
/// Los precios de los activos están en dólares (USD); la app los convierte a
/// pesos colombianos según la moneda que elija el usuario.
/// Cuando conectemos un proveedor de datos real (API de precios, Firestore,
/// etc.), este archivo se reemplaza por esa fuente.
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
    imageAsset: 'assets/images/learn_interest.png',
    type: ContentType.info,
    relatedAssetIds: ['i2', 'i1'],
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
    imageAsset: 'assets/images/learn_diversify.png',
    type: ContentType.info,
    relatedAssetIds: ['i1', 'i2', 'i4', 'i5'],
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
    imageAsset: 'assets/images/learn_risk.png',
    type: ContentType.info,
    relatedAssetIds: ['i2', 'i3'],
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
    imageAsset: 'assets/images/learn_emergency.png',
    type: ContentType.info,
    relatedAssetIds: ['i2'],
  ),
  ContentItem(
    id: 'a5',
    title: '¿Qué es un ETF y por qué es popular?',
    category: 'Productos',
    summary: 'Una canasta de muchas inversiones en una sola compra.',
    body:
        'Un ETF (fondo cotizado en bolsa) agrupa decenas o cientos de activos, '
        'como las acciones de un índice, y se compra y se vende como si fuera una '
        'sola acción.\n\n'
        'Ventajas: diversificación inmediata, comisiones bajas y facilidad para '
        'empezar con poco dinero.\n\n'
        'Ojo: que sea diverso no significa que esté libre de riesgo. Si el '
        'mercado completo cae, el ETF también cae.',
    imageAsset: 'assets/images/learn_etf.png',
    type: ContentType.info,
    relatedAssetIds: ['i1', 'i4'],
  ),
  ContentItem(
    id: 'a6',
    title: 'Inflación: por qué tu dinero pierde valor',
    category: 'Fundamentos',
    summary: 'Guardar plata sin invertir tiene un costo escondido.',
    body:
        'La inflación es el aumento general de los precios. Si los precios suben '
        '8% en un año y tu dinero guardado no rinde nada, hoy compras 8% menos '
        'que antes con la misma plata.\n\n'
        'Por eso invertir no es solo "ganar más": también es proteger el poder '
        'de compra. Los bonos ligados a la inflación, los bienes raíces y el oro '
        'suelen usarse con ese fin.',
    imageAsset: 'assets/images/learn_inflation.png',
    type: ContentType.info,
    relatedAssetIds: ['i2', 'i4', 'i5'],
  ),
  ContentItem(
    id: 'a7',
    title: '5 errores comunes del inversionista principiante',
    category: 'Estrategia',
    summary: 'Evítalos y ahórrate más de un susto.',
    body:
        '1. Invertir dinero que necesitas a corto plazo.\n'
        '2. Poner todo en un solo activo.\n'
        '3. Comprar por moda o por un "dato seguro".\n'
        '4. Vender en pánico cuando el mercado cae.\n'
        '5. No entender en qué estás invirtiendo.\n\n'
        'Practicar en un simulador, como este, es una excelente forma de cometer '
        'errores sin que cuesten dinero real.',
    imageAsset: 'assets/images/learn_mistakes.png',
    type: ContentType.info,
    relatedAssetIds: ['i1', 'i3'],
  ),

  // ---------- ACTIVOS DE INVERSIÓN (precios en USD) ----------
  ContentItem(
    id: 'i1',
    title: 'ETF S&P 500',
    category: 'Renta variable',
    summary: 'Las 500 empresas más grandes de Estados Unidos.',
    body:
        'Un ETF que replica el índice S&P 500. Baja comisión, alta liquidez y '
        'exposición amplia al mercado estadounidense.\n\n'
        'Históricamente ha entregado retornos anuales cercanos al 10% en promedios '
        'de 10 años o más, con volatilidad importante en el corto plazo. Los '
        'rendimientos pasados no garantizan resultados futuros.',
    imageAsset: 'assets/images/asset_sp500.png',
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
    imageAsset: 'assets/images/asset_bond.png',
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
    imageAsset: 'assets/images/asset_tech.png',
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
    imageAsset: 'assets/images/asset_reit.png',
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
    imageAsset: 'assets/images/asset_gold.png',
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

/// Consejos cortos que rotan cada día.
const List<String> kDailyTips = [
  'Invierte solo dinero que no vayas a necesitar en el corto plazo.',
  'Diversificar no elimina el riesgo, pero lo reparte.',
  'El tiempo en el mercado suele valer más que adivinar el mejor momento.',
  'Antes de comprar, pregúntate: ¿entiendo en qué estoy invirtiendo?',
  'Las comisiones pequeñas, con los años, se vuelven grandes.',
  'Un fondo de emergencia te evita vender tus inversiones en mal momento.',
  'Las caídas son normales: lo importante es tener un plan antes de que pasen.',
];

/// Consejo del día (cambia cada día; [now] solo se usa en pruebas).
String dailyTip([DateTime? now]) {
  final date = now ?? DateTime.now();
  final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
  return kDailyTips[dayOfYear % kDailyTips.length];
}
