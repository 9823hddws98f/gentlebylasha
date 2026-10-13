import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/utils/app_config.dart';

void main() {
  group('legal and help links follow the app language', () {
    test('Dutch uses the root paths', () {
      expect(AppConfig.privacyUrl('nl').toString(), 'https://gentle-website.vercel.app/privacy');
      expect(AppConfig.termsUrl('nl').toString(), 'https://gentle-website.vercel.app/voorwaarden');
      expect(AppConfig.helpUrl('nl').toString(), 'https://gentle-website.vercel.app/help');
      expect(AppConfig.websiteUrl('nl').toString(), 'https://gentle-website.vercel.app/');
    });

    test('English uses /en', () {
      expect(AppConfig.privacyUrl('en').toString(), 'https://gentle-website.vercel.app/en/privacy');
      expect(AppConfig.termsUrl('en').toString(), 'https://gentle-website.vercel.app/en/terms');
      expect(AppConfig.helpUrl('en').toString(), 'https://gentle-website.vercel.app/en/help');
      expect(AppConfig.websiteUrl('en').toString(), 'https://gentle-website.vercel.app/en');
    });
  });

  test('share links point at the webapp', () {
    expect(AppConfig.shareLink('shareTrack', 'abc'), 'https://gentle-mu.vercel.app/shareTrack/abc');
  });
}
