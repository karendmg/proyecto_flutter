# InverApp

Repositorio de información financiera conectado a un **simulador de inversión**
(dinero virtual), hecho con Flutter, Dart y Firebase.

## Qué incluye

| Pestaña | Qué hace |
|---|---|
| **Aprende** | Saludo, progreso de lectura, consejo del día y 7 artículos, cada uno con su ilustración. Cada artículo enlaza a activos del simulador para ponerlo en práctica. |
| **Invertir** | Catálogo de activos con precio y variación, filtros por categoría y favoritos (⭐). Al tocar uno: gráfica de precio + comprar/vender. |
| **Portafolio** | Valor total, ganancia/pérdida, distribución por categoría, posiciones e historial. |
| **Perfil** | Datos de la cuenta, resumen (efectivo, invertido, lecturas, favoritos) y cierre de sesión. |

Barra superior con logo y nombre y selector de moneda **USD | COP**. El perfil
se abre solo desde la pestaña "Perfil".
Además: login / registro, **recuperar contraseña** (solo desde el inicio de
sesión), modo claro/oscuro/sistema (se recuerda) y reinicio del simulador
(Configuración).

## Moneda

Todo se guarda en **dólares**. Al elegir COP, la app multiplica por la tasa del
día (ExchangeRate-API, sin llave). Si no hay internet usa la última tasa
guardada o una de respaldo (~3.300 COP/USD). La tasa es de referencia del
mercado, **no** la TRM oficial. Se actualiza sola cada 12 h o a mano desde
Configuración.

## Cómo correrlo

```bash
flutter pub get
flutter run            # o elige un dispositivo en VS Code
flutter test           # pruebas (no requieren Firebase)
```

## Firebase

1. **Authentication** → proveedor *Correo electrónico/contraseña* habilitado.
   Opcional: en *Plantillas* → *Restablecimiento de contraseña* puedes
   personalizar el correo (remitente, asunto y texto).
2. **Firestore Database** → publica las reglas de `firestore.rules`.

Estructura de datos:

```
users/{uid}                     { cash, favorites[], read[] }
users/{uid}/holdings/{assetId}  { shares, avgPrice, title, category }
users/{uid}/trades/{id}         { assetId, title, side, shares, price, total, date }
```

Las compras y ventas usan **transacciones** de Firestore: el efectivo, la
posición y el historial se actualizan juntos o no se actualiza nada.

## Estructura

```
assets/images/  ilustraciones (cada artículo y activo tiene la suya)
lib/
  config/     router, tema
  data/       datos de ejemplo (mock_data.dart)
  models/     ContentItem, Holding, TradeRecord
  services/   Auth, Portfolio, UserData (favoritos/lecturas), Currency, Theme
  pages/      login, registro, recuperar contraseña, home, detalle, ajustes + tabs/
  widgets/    componentes reutilizables
  utils/      formateo, validadores, historial de precios simulado
```

## Siguientes pasos

- Precios reales: reemplazar `mock_data.dart` por una API de datos de mercado
  (y el historial simulado de `utils/price_history.dart` por velas reales).
- Operar con dinero real exige un bróker regulado con API propia y cumplir la
  normativa local; la app hoy es solo educativa.
