import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/domain/services/language_cubit.dart';

void main() {
  group('LanguageCubit.resolveLanguageCode', () {
    test('a saved choice wins', () {
      expect(LanguageCubit.resolveLanguageCode(saved: 'en', deviceLanguage: 'nl'), 'en');
      expect(LanguageCubit.resolveLanguageCode(saved: 'nl', deviceLanguage: 'en'), 'nl');
    });

    test('without a choice, a Dutch device gets Dutch', () {
      expect(LanguageCubit.resolveLanguageCode(deviceLanguage: 'nl'), 'nl');
    });

    test('any other device language gets English', () {
      expect(LanguageCubit.resolveLanguageCode(deviceLanguage: 'en'), 'en');
      expect(LanguageCubit.resolveLanguageCode(deviceLanguage: 'de'), 'en');
    });

    test('an unknown saved value is ignored', () {
      expect(LanguageCubit.resolveLanguageCode(saved: 'fr', deviceLanguage: 'nl'), 'nl');
    });
  });
}
