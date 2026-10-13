import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/domain/cubits/entitlement_cubit.dart';

void main() {
  final now = DateTime(2026, 10, 12);

  group('Entitlement.isPremiumAt', () {
    test('no subscription is not premium', () {
      expect(const Entitlement().isPremiumAt(now), isFalse);
    });

    test('active without expiry is lifetime premium', () {
      expect(const Entitlement(active: true).isPremiumAt(now), isTrue);
    });

    test('active until a future date is premium', () {
      final e = Entitlement(active: true, expiresAt: now.add(const Duration(days: 1)));
      expect(e.isPremiumAt(now), isTrue);
    });

    test('expired is not premium', () {
      final e = Entitlement(active: true, expiresAt: now.subtract(const Duration(days: 1)));
      expect(e.isPremiumAt(now), isFalse);
    });

    test('inactive is not premium even without expiry', () {
      expect(const Entitlement(active: false).isPremiumAt(now), isFalse);
    });
  });

  group('Entitlement.canPlay', () {
    test('free tracks are always playable', () {
      expect(const Entitlement().canPlay(premiumTrack: false, now: now), isTrue);
    });

    test('premium tracks need premium', () {
      expect(const Entitlement().canPlay(premiumTrack: true, now: now), isFalse);
      expect(const Entitlement(active: true).canPlay(premiumTrack: true, now: now), isTrue);
    });
  });

  group('EntitlementCubit.expiryCheckDelay', () {
    test('lifetime and free need no check', () {
      expect(EntitlementCubit.expiryCheckDelay(const Entitlement(active: true), now), isNull);
      expect(EntitlementCubit.expiryCheckDelay(const Entitlement(), now), isNull);
    });

    test('checks just after premium ends', () {
      final e = Entitlement(active: true, expiresAt: now.add(const Duration(hours: 2)));
      expect(EntitlementCubit.expiryCheckDelay(e, now), const Duration(hours: 2, seconds: 1));
    });

    test('far-away expiries are checked again after a week', () {
      final e = Entitlement(active: true, expiresAt: now.add(const Duration(days: 365)));
      expect(EntitlementCubit.expiryCheckDelay(e, now), EntitlementCubit.maxExpiryWait);
    });

    test('already expired needs no check', () {
      final e = Entitlement(active: true, expiresAt: now.subtract(const Duration(minutes: 1)));
      expect(EntitlementCubit.expiryCheckDelay(e, now), isNull);
    });
  });
}
