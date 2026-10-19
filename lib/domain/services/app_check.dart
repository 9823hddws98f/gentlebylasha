import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// Firebase App Check: lets Firestore, Storage, Auth and the functions tell
/// that a request comes from a genuine Gentle build.
///
/// Off unless the app is built with `--dart-define=APP_CHECK=true`. Switch it
/// on only after the apps are registered under Firebase console → App Check
/// (docs/launch-checklist.md). A web release build also needs
/// `--dart-define=RECAPTCHA_SITE_KEY=…`, the reCAPTCHA Enterprise key that is
/// registered for the web app. Debug builds use the debug providers; their
/// token is printed in the log and has to be registered once. Pass a token
/// that is already registered with `--dart-define=APP_CHECK_DEBUG_TOKEN=…`, so
/// it survives reinstalls.
class AppCheckSetup {
  static const enabled = bool.fromEnvironment('APP_CHECK');
  static const _siteKey = String.fromEnvironment('RECAPTCHA_SITE_KEY');
  static const _debugToken = String.fromEnvironment('APP_CHECK_DEBUG_TOKEN');

  /// Call right after `Firebase.initializeApp`, so every request after it
  /// carries a token. Never against the emulators: they don't check tokens.
  static Future<void> activate() async {
    final providers = AppCheckProviders.choose(
      enabled: enabled,
      web: kIsWeb,
      debug: kDebugMode,
      siteKey: _siteKey,
      debugToken: _debugToken,
    );
    if (providers == null) {
      if (enabled) debugPrint('App Check stays off: the web needs --dart-define=RECAPTCHA_SITE_KEY=…');
      return;
    }
    try {
      final appCheck = FirebaseAppCheck.instance;
      await appCheck.activate(
        providerAndroid: providers.android,
        providerApple: providers.apple,
        providerWeb: providers.web,
      );
      await appCheck.setTokenAutoRefreshEnabled(true);
      if (providers.debug) debugPrint(_debugHelp);
    } catch (e) {
      // Until enforcement is on, requests still go through without a token.
      debugPrint('App Check could not start: $e');
    }
  }

  static String get _debugHelp => _debugToken.isNotEmpty
      ? 'App Check uses the debug provider with APP_CHECK_DEBUG_TOKEN. That token must be '
          'listed under Firebase console → App Check → Apps → ⋮ → Manage debug tokens.'
      : 'App Check uses the debug provider. Add its token once under Firebase console → '
          'App Check → Apps → ⋮ → Manage debug tokens. Find it in the log: Android logcat '
          '"DebugAppCheckProvider", Xcode console "Firebase App Check Debug Token", browser '
          'console "App Check debug token". Or pass a registered token with '
          '--dart-define=APP_CHECK_DEBUG_TOKEN=…';
}

/// The App Check providers for one build, chosen without touching Firebase.
class AppCheckProviders {
  const AppCheckProviders._({required this.android, required this.apple, this.web, required this.debug});

  final AndroidAppCheckProvider android;
  final AppleAppCheckProvider apple;

  /// Only on the web.
  final WebProvider? web;

  /// Debug providers: the token has to be registered in the console.
  final bool debug;

  /// Null when App Check stays off: not switched on, or a web release build
  /// without a reCAPTCHA key.
  static AppCheckProviders? choose({
    required bool enabled,
    required bool web,
    required bool debug,
    required String siteKey,
    String debugToken = '',
  }) {
    if (!enabled) return null;
    final token = debugToken.isEmpty ? null : debugToken;
    if (debug) {
      return AppCheckProviders._(
        android: AndroidDebugProvider(debugToken: token),
        apple: AppleDebugProvider(debugToken: token),
        web: web ? WebDebugProvider(debugToken: token) : null,
        debug: true,
      );
    }
    if (web && siteKey.isEmpty) return null;
    return AppCheckProviders._(
      android: const AndroidPlayIntegrityProvider(),
      // App Attest where the device supports it, DeviceCheck otherwise.
      apple: const AppleAppAttestWithDeviceCheckFallbackProvider(),
      web: web ? ReCaptchaEnterpriseProvider(siteKey) : null,
      debug: false,
    );
  }
}
