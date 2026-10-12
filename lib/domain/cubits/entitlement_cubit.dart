import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Premium access of the signed-in user, read from `subscriptions/{uid}`.
/// That document is written only by Cloud Functions (store purchase, Stripe
/// or a redeemed access code).
class Entitlement {
  final bool active;

  /// null with [active] = lifetime access.
  final DateTime? expiresAt;

  /// 'apple' | 'google' | 'stripe' | 'code' | 'manual'
  final String? source;

  const Entitlement({this.active = false, this.expiresAt, this.source});

  bool isPremiumAt(DateTime now) =>
      active && (expiresAt == null || expiresAt!.isAfter(now));

  bool get isPremium => isPremiumAt(DateTime.now());

  bool canPlay({required bool premiumTrack, DateTime? now}) =>
      !premiumTrack || isPremiumAt(now ?? DateTime.now());

  static Entitlement fromMap(Map<String, dynamic>? map) {
    if (map == null) return const Entitlement();
    return Entitlement(
      active: map['active'] == true,
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
      source: map['source'] as String?,
    );
  }
}

class EntitlementCubit extends Cubit<Entitlement> {
  static final EntitlementCubit instance = EntitlementCubit._();
  EntitlementCubit._() : super(const Entitlement());

  StreamSubscription? _sub;

  Future<void> init() async {
    await _sub?.cancel();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return emit(const Entitlement());
    _sub = FirebaseFirestore.instance
        .collection('subscriptions')
        .doc(uid)
        .snapshots()
        .listen(
          (snap) => emit(Entitlement.fromMap(snap.data())),
          onError: (_) => emit(const Entitlement()),
        );
  }

  Future<void> reset() async {
    await _sub?.cancel();
    _sub = null;
    emit(const Entitlement());
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
