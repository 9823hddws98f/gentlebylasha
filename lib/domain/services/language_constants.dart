import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/utils/get.dart';

import '/main.dart';

class TranslationService {
  TranslationService._();

  static final TranslationService instance = TranslationService._();

  AppLocalizations translation() =>
      AppLocalizations.of(MyApp.navigatorKey.currentContext!)!;

  static const String LAGUAGE_CODE = 'languageCode';

  static const String ENGLISH = 'en';
  static const String GERMAN = 'de';

  Future<Locale> setLocale(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(LAGUAGE_CODE, languageCode);
    return _locale(languageCode);
  }

  Future<String> getLanguageCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString(LAGUAGE_CODE) ?? ENGLISH;
    return languageCode;
  }

  Future<Locale> getLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString(LAGUAGE_CODE) ?? ENGLISH;
    return _locale(languageCode);
  }

  Locale _locale(String languageCode) => switch (languageCode) {
        ENGLISH => const Locale(ENGLISH, ''),
        GERMAN => const Locale(GERMAN, ''),
        _ => const Locale(ENGLISH, '')
      };
}

mixin Translation {
  final tr = Get.the<TranslationService>().translation();
}
