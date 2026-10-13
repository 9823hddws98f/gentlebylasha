/// URLs the app links to. Override per build with
/// `--dart-define=SITE_URL=https://…` and `--dart-define=APP_URL=https://…`
/// once Gentle has its own domain.
class AppConfig {
  AppConfig._();

  /// Marketing website with the legal and help pages.
  static const siteUrl = String.fromEnvironment(
    'SITE_URL',
    defaultValue: 'https://gentle-website.vercel.app',
  );

  /// Customer webapp; also the host of shared track/playlist links. Keep in sync
  /// with `appLinkHost` (android/app/build.gradle.kts) and the associated
  /// domain in ios/Runner/Runner.entitlements.
  static const appUrl = String.fromEnvironment(
    'APP_URL',
    defaultValue: 'https://gentle-mu.vercel.app',
  );

  /// Website home in the app language.
  static Uri websiteUrl(String languageCode) => _site(languageCode == 'nl' ? '/' : '/en');

  static Uri privacyUrl(String languageCode) =>
      _site(languageCode == 'nl' ? '/privacy' : '/en/privacy');

  static Uri termsUrl(String languageCode) =>
      _site(languageCode == 'nl' ? '/voorwaarden' : '/en/terms');

  static Uri helpUrl(String languageCode) => _site(languageCode == 'nl' ? '/help' : '/en/help');

  static Uri _site(String path) => Uri.parse(_trimSlash(siteUrl) + path);

  static String _trimSlash(String url) =>
      url.endsWith('/') ? url.substring(0, url.length - 1) : url;

  /// Link that opens [type] (`shareTrack` / `sharePlaylist`) with [id] in the app.
  static String shareLink(String type, String id) => '${_trimSlash(appUrl)}/$type/$id';
}
