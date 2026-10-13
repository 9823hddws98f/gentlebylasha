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

  /// Paid subscriptions that are running, whether or not they are the source
  /// that currently grants premium. Each can be managed or cancelled.
  final Set<String> billingSources;

  const Entitlement({
    this.active = false,
    this.expiresAt,
    this.source,
    this.billingSources = const {},
  });

  /// A new instance with the same values (re-emitted when premium expires).
  Entitlement.copy(Entitlement e)
      : active = e.active,
        expiresAt = e.expiresAt,
        source = e.source,
        billingSources = e.billingSources;

  bool isPremiumAt(DateTime now) =>
      active && (expiresAt == null || expiresAt!.isAfter(now));

  bool get isPremium => isPremiumAt(DateTime.now());

  bool canPlay({required bool premiumTrack, DateTime? now}) =>
      !premiumTrack || isPremiumAt(now ?? DateTime.now());

  static Entitlement fromMap(Map<String, dynamic>? map) {
    if (map == null) return const Entitlement();
    final sources = (map['sources'] as Map<String, dynamic>?) ?? {};
    final now = DateTime.now();
    return Entitlement(
      active: map['active'] == true,
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
      source: map['source'] as String?,
      billingSources: {
        for (final MapEntry(:key, :value) in sources.entries)
          if (const {'stripe', 'apple', 'google'}.contains(key) &&
              value is Map &&
              value['active'] == true &&
              ((value['expiresAt'] as Timestamp?)?.toDate().isAfter(now) ?? true))
            key,
      },
    );
  }
}

class EntitlementCubit extends Cubit<Entitlement> {
  static final EntitlementCubit instance = EntitlementCubit._();
  EntitlementCubit._() : super(const Entitlement());

  StreamSubscription? _sub;
  Timer? _expiryTimer;

  /// Longest single wait for an expiry. Browsers fire longer timers right away.
  static const maxExpiryWait = Duration(days: 7);

  /// How long to wait before checking premium again because it expires; null
  /// when it doesn't expire (lifetime) or isn't active.
  static Duration? expiryCheckDelay(Entitlement e, DateTime now) {
    if (!e.isPremiumAt(now) || e.expiresAt == null) return null;
    // A second late, so isPremium is false when the check runs.
    final wait = e.expiresAt!.difference(now) + const Duration(seconds: 1);
    return wait > maxExpiryWait ? maxExpiryWait : wait;
  }

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
  void onChange(Change<Entitlement> change) {
    super.onChange(change);
    _scheduleExpiryCheck(change.nextState);
  }

  /// Premium ends at expiresAt without the document changing; emit again then,
  /// so the paywall, premium locks and push topics (PushService) follow.
  void _scheduleExpiryCheck(Entitlement e) {
    _expiryTimer?.cancel();
    final wait = expiryCheckDelay(e, DateTime.now());
    if (wait == null) return;
    _expiryTimer = Timer(wait, () {
      if (!isClosed && identical(state, e)) emit(Entitlement.copy(e));
    });
  }

  @override
  Future<void> close() async {
    _expiryTimer?.cancel();
    await _sub?.cancel();
    return super.close();
  }
}
