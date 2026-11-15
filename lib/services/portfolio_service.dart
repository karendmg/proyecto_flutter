import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/content_item.dart';
import '../models/portfolio_models.dart';
import 'currency_service.dart';

/// Efectivo virtual con el que arranca cada usuario en el simulador.
const double kInitialCash = 10000.0;

/// Portafolio del usuario, guardado en Firestore:
///
///   users/{uid}                    -> { cash }
///   users/{uid}/holdings/{assetId} -> { shares, avgPrice, title, category }
///   users/{uid}/trades/{id}        -> historial de compras y ventas
///
/// Es un singleton y un [ChangeNotifier]: escucha Firestore en vivo y avisa a
/// la interfaz. Cuando el usuario cierra sesión o cambia de cuenta, se limpia
/// y se vuelve a enlazar solo.
class PortfolioService extends ChangeNotifier {
  PortfolioService._() {
    FirebaseAuth.instance.authStateChanges().listen(_bind);
  }

  static final PortfolioService instance = PortfolioService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _holdingsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _tradesSub;

  String? _uid;
  double _cash = kInitialCash;
  Map<String, Holding> _holdings = {};
  List<TradeRecord> _trades = [];
  bool _loading = true;
  String? _error;

  // ---------------- Estado ----------------

  double get cash => _cash;
  bool get isLoading => _loading;

  /// Mensaje de error de Firestore (permisos, red...), o null si todo va bien.
  String? get error => _error;

  /// Posiciones ordenadas por nombre.
  List<Holding> get holdings {
    final list = _holdings.values.toList();
    list.sort((a, b) => a.title.compareTo(b.title));
    return list;
  }

  /// Últimos movimientos (el más reciente primero).
  List<TradeRecord> get trades => List.unmodifiable(_trades);

  Holding? holdingOf(String assetId) => _holdings[assetId];

  int sharesOf(String assetId) => _holdings[assetId]?.shares ?? 0;

  // ---------------- Cálculos ----------------

  Map<String, ContentItem> _byId(List<ContentItem> assets) =>
      {for (final a in assets) a.id: a};

  /// Valor actual de las posiciones (unidades × precio de mercado).
  double investedValue(List<ContentItem> assets) {
    final byId = _byId(assets);
    var total = 0.0;
    for (final h in _holdings.values) {
      final price = byId[h.assetId]?.price ?? h.avgPrice;
      total += price * h.shares;
    }
    return total;
  }

  /// Lo que costó construir las posiciones actuales.
  double get costBasis {
    var total = 0.0;
    for (final h in _holdings.values) {
      total += h.cost;
    }
    return total;
  }

  /// Valor total: efectivo + invertido.
  double totalValue(List<ContentItem> assets) => _cash + investedValue(assets);

  /// Ganancia o pérdida no realizada.
  double profit(List<ContentItem> assets) => investedValue(assets) - costBasis;

  double profitPercent(List<ContentItem> assets) {
    final cost = costBasis;
    return cost == 0 ? 0.0 : profit(assets) / cost * 100;
  }

  // ---------------- Enlace con Firestore ----------------

  void _cancelSubs() {
    _userSub?.cancel();
    _holdingsSub?.cancel();
    _tradesSub?.cancel();
    _userSub = null;
    _holdingsSub = null;
    _tradesSub = null;
  }

  void _bind(User? user) {
    _cancelSubs();
    _uid = user?.uid;
    _cash = kInitialCash;
    _holdings = {};
    _trades = [];
    _error = null;

    if (user == null) {
      _loading = false;
      notifyListeners();
      return;
    }

    _loading = true;
    notifyListeners();

    final base = _db.collection('users').doc(user.uid);

    _userSub = base.snapshots().listen((snap) {
      // Si el documento aún no existe, el usuario parte con el efectivo inicial.
      _cash = (snap.data()?['cash'] as num?)?.toDouble() ?? kInitialCash;
      _loading = false;
      _error = null;
      notifyListeners();
    }, onError: _onError);

    _holdingsSub = base.collection('holdings').snapshots().listen((snap) {
      _holdings = {for (final d in snap.docs) d.id: Holding.fromDoc(d)};
      notifyListeners();
    }, onError: _onError);

    _tradesSub = base
        .collection('trades')
        .orderBy('date', descending: true)
        .limit(50)
        .snapshots()
        .listen((snap) {
      _trades = snap.docs.map(TradeRecord.fromDoc).toList();
      notifyListeners();
    }, onError: _onError);
  }

  void _onError(Object e) {
    _error = _friendly(e);
    _loading = false;
    notifyListeners();
  }

  String _friendly(Object e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return 'Firestore rechazó el acceso. Revisa las reglas de seguridad de tu proyecto.';
        case 'unavailable':
        case 'deadline-exceeded':
          return 'Sin conexión con el servidor. Revisa tu internet e intenta de nuevo.';
        default:
          return 'Error de Firestore (${e.code}).';
      }
    }
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }

  double _round2(double v) => (v * 100).roundToDouble() / 100;

  // ---------------- Operaciones ----------------

  /// Compra [shares] unidades de [asset]. La operación es atómica: o se
  /// descuenta el efectivo, se actualiza la posición y se guarda el historial,
  /// o no pasa nada.
  Future<TradeResult> buy(ContentItem asset, int shares) async {
    final uid = _uid;
    if (uid == null) {
      return const TradeResult.failure('Inicia sesión para operar.');
    }
    if (shares <= 0) {
      return const TradeResult.failure('Ingresa una cantidad mayor a cero.');
    }

    final cost = _round2(asset.price * shares);
    final userRef = _db.collection('users').doc(uid);
    final holdRef = userRef.collection('holdings').doc(asset.id);
    final tradeRef = userRef.collection('trades').doc();

    try {
      return await _db.runTransaction<TradeResult>((tx) async {
        final userSnap = await tx.get(userRef);
        final holdSnap = await tx.get(holdRef);

        final cash =
            (userSnap.data()?['cash'] as num?)?.toDouble() ?? kInitialCash;
        if (cost > cash + 0.005) {
          return const TradeResult.failure(
            'Efectivo insuficiente para esta compra.',
          );
        }

        final held = (holdSnap.data()?['shares'] as num?)?.toInt() ?? 0;
        final heldAvg =
            (holdSnap.data()?['avgPrice'] as num?)?.toDouble() ?? 0.0;
        final newShares = held + shares;
        final newAvg = _round2(((held * heldAvg) + cost) / newShares);

        tx.set(userRef, {'cash': _round2(cash - cost)}, SetOptions(merge: true));
        tx.set(holdRef, {
          'title': asset.title,
          'category': asset.category,
          'shares': newShares,
          'avgPrice': newAvg,
        });
        tx.set(tradeRef, {
          'assetId': asset.id,
          'title': asset.title,
          'side': 'buy',
          'shares': shares,
          'price': asset.price,
          'total': cost,
          'date': FieldValue.serverTimestamp(),
        });

        return TradeResult.success(
          'Compraste $shares × ${asset.title} por ${CurrencyService.instance.format(cost)}.',
        );
      }, timeout: const Duration(seconds: 15));
    } on FirebaseException catch (e) {
      return TradeResult.failure(_friendly(e));
    } catch (_) {
      return const TradeResult.failure(
        'No se pudo completar la compra. Intenta de nuevo.',
      );
    }
  }

  /// Vende [shares] unidades de [asset] (también de forma atómica).
  Future<TradeResult> sell(ContentItem asset, int shares) async {
    final uid = _uid;
    if (uid == null) {
      return const TradeResult.failure('Inicia sesión para operar.');
    }
    if (shares <= 0) {
      return const TradeResult.failure('Ingresa una cantidad mayor a cero.');
    }

    final proceeds = _round2(asset.price * shares);
    final userRef = _db.collection('users').doc(uid);
    final holdRef = userRef.collection('holdings').doc(asset.id);
    final tradeRef = userRef.collection('trades').doc();

    try {
      return await _db.runTransaction<TradeResult>((tx) async {
        final userSnap = await tx.get(userRef);
        final holdSnap = await tx.get(holdRef);

        final cash =
            (userSnap.data()?['cash'] as num?)?.toDouble() ?? kInitialCash;
        final held = (holdSnap.data()?['shares'] as num?)?.toInt() ?? 0;
        if (shares > held) {
          return TradeResult.failure(
            held == 0
                ? 'No tienes unidades de este activo.'
                : 'Solo tienes $held unidades de este activo.',
          );
        }

        final left = held - shares;
        tx.set(
          userRef,
          {'cash': _round2(cash + proceeds)},
          SetOptions(merge: true),
        );
        if (left == 0) {
          tx.delete(holdRef);
        } else {
          tx.set(holdRef, {'shares': left}, SetOptions(merge: true));
        }
        tx.set(tradeRef, {
          'assetId': asset.id,
          'title': asset.title,
          'side': 'sell',
          'shares': shares,
          'price': asset.price,
          'total': proceeds,
          'date': FieldValue.serverTimestamp(),
        });

        return TradeResult.success(
          'Vendiste $shares × ${asset.title} por ${CurrencyService.instance.format(proceeds)}.',
        );
      }, timeout: const Duration(seconds: 15));
    } on FirebaseException catch (e) {
      return TradeResult.failure(_friendly(e));
    } catch (_) {
      return const TradeResult.failure(
        'No se pudo completar la venta. Intenta de nuevo.',
      );
    }
  }

  /// Borra posiciones e historial y devuelve el efectivo al valor inicial.
  Future<TradeResult> resetSimulator() async {
    final uid = _uid;
    if (uid == null) {
      return const TradeResult.failure('Inicia sesión primero.');
    }
    try {
      final base = _db.collection('users').doc(uid);
      final refs = <DocumentReference<Map<String, dynamic>>>[];
      final holdings = await base.collection('holdings').get();
      final trades = await base.collection('trades').get();
      for (final d in holdings.docs) {
        refs.add(d.reference);
      }
      for (final d in trades.docs) {
        refs.add(d.reference);
      }

      // Firestore permite máximo 500 operaciones por lote.
      for (var i = 0; i < refs.length; i += 400) {
        final end = (i + 400 < refs.length) ? i + 400 : refs.length;
        final batch = _db.batch();
        for (final ref in refs.sublist(i, end)) {
          batch.delete(ref);
        }
        await batch.commit();
      }
      await base.set({'cash': kInitialCash}, SetOptions(merge: true));
      return const TradeResult.success('Simulador reiniciado.');
    } on FirebaseException catch (e) {
      return TradeResult.failure(_friendly(e));
    } catch (_) {
      return const TradeResult.failure('No se pudo reiniciar. Intenta de nuevo.');
    }
  }
}
