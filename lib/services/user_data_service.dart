import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Datos personales del usuario guardados en Firestore, en el mismo documento
/// `users/{uid}` que usa el portafolio:
///
///   favorites: [ids de activos marcados con estrella]
///   read:      [ids de artículos marcados como leídos]
///
/// Se actualiza en vivo y se limpia solo al cerrar sesión.
class UserDataService extends ChangeNotifier {
  UserDataService._() {
    FirebaseAuth.instance.authStateChanges().listen(_bind);
  }

  static final UserDataService instance = UserDataService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;
  String? _uid;
  Set<String> _favorites = {};
  Set<String> _read = {};

  bool isFavorite(String id) => _favorites.contains(id);
  bool isRead(String id) => _read.contains(id);
  int get favoritesCount => _favorites.length;
  int get readCount => _read.length;

  void _bind(User? user) {
    _sub?.cancel();
    _sub = null;
    _uid = user?.uid;
    _favorites = {};
    _read = {};
    notifyListeners();
    if (user == null) return;

    _sub = _db.collection('users').doc(user.uid).snapshots().listen((snap) {
      final data = snap.data();
      _favorites = _toSet(data?['favorites']);
      _read = _toSet(data?['read']);
      notifyListeners();
    }, onError: (Object _) {});
  }

  Set<String> _toSet(Object? value) =>
      value is List ? value.whereType<String>().toSet() : <String>{};

  Future<bool> _toggle(String field, String id, bool add) async {
    final uid = _uid;
    if (uid == null) return false;
    try {
      await _db.collection('users').doc(uid).set({
        field: add ? FieldValue.arrayUnion([id]) : FieldValue.arrayRemove([id]),
      }, SetOptions(merge: true));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Marca o desmarca un activo como favorito. false si no se pudo guardar.
  Future<bool> toggleFavorite(String id) =>
      _toggle('favorites', id, !_favorites.contains(id));

  /// Marca o desmarca un artículo como leído. false si no se pudo guardar.
  Future<bool> setRead(String id, bool read) => _toggle('read', id, read);
}
