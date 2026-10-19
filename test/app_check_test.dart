import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/domain/services/app_check.dart';

void main() {
  test('off unless APP_CHECK is set', () {
    expect(AppCheckSetup.enabled, isFalse);
    for (final web in [false, true]) {
      for (final debug in [false, true]) {
        expect(AppCheckProviders.choose(enabled: false, web: web, debug: debug, siteKey: 'key'), isNull);
      }
    }
  });

  test('release apps use Play Integrity and App Attest with DeviceCheck fallback', () {
    final p = AppCheckProviders.choose(enabled: true, web: false, debug: false, siteKey: '')!;
    expect(p.android, isA<AndroidPlayIntegrityProvider>());
    expect(p.apple, isA<AppleAppAttestWithDeviceCheckFallbackProvider>());
    expect(p.web, isNull);
    expect(p.debug, isFalse);
  });

  test('web release uses reCAPTCHA Enterprise, and stays off without a key', () {
    final p = AppCheckProviders.choose(enabled: true, web: true, debug: false, siteKey: 'site-key')!;
    expect(p.web, isA<ReCaptchaEnterpriseProvider>());
    expect(p.web!.siteKey, 'site-key');
    expect(AppCheckProviders.choose(enabled: true, web: true, debug: false, siteKey: ''), isNull);
  });

  test('debug builds use the debug providers, with an optional fixed token', () {
    final generated = AppCheckProviders.choose(enabled: true, web: true, debug: true, siteKey: '')!;
    expect(generated.debug, isTrue);
    expect((generated.android as AndroidDebugProvider).debugToken, isNull);
    expect((generated.apple as AppleDebugProvider).debugToken, isNull);
    expect((generated.web as WebDebugProvider).debugToken, isNull);

    final fixed = AppCheckProviders.choose(enabled: true, web: false, debug: true, siteKey: '', debugToken: 'tok')!;
    expect((fixed.android as AndroidDebugProvider).debugToken, 'tok');
    expect((fixed.apple as AppleDebugProvider).debugToken, 'tok');
    expect(fixed.web, isNull);
  });
}
