import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gentle/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/utils/get.dart';
import '/utils/localized_content.dart';

enum AppLanguage {
  english('en'),
  dutch('nl');

  final String languageCode;

  String get displayName => switch (this) {
        AppLanguage.english => 'English',
        AppLanguage.dutch => 'Nederlands',
      };

  const AppLanguage(this.languageCode);
}

class LanguageState {
  final Locale locale;
  const LanguageState(this.locale);
}

class LanguageCubit extends Cubit<LanguageState> {
  static const _prefsKey = 'languageCode';
  static final instance = LanguageCubit._();

  LanguageCubit._() : super(LanguageState(Locale(resolveLanguageCode()))) {
    _applyLanguage(state.locale.languageCode);
    loadSavedLanguage();
  }

  /// The language the user picked, or else the device language when it is
  /// Dutch, or else English.
  static String resolveLanguageCode({String? saved, String? deviceLanguage}) {
    if (AppLanguage.values.any((l) => l.languageCode == saved)) return saved!;
    final device = deviceLanguage ?? PlatformDispatcher.instance.locale.languageCode;
    return device == AppLanguage.dutch.languageCode
        ? AppLanguage.dutch.languageCode
        : AppLanguage.english.languageCode;
  }

  /// The app language as stored, for code that runs before the cubit exists.
  static Future<String> loadLanguageCode() async => resolveLanguageCode(
        saved: (await SharedPreferences.getInstance()).getString(_prefsKey),
      );

  String get languageCode => state.locale.languageCode;

  AppLocalizations get translation => lookupAppLocalizations(state.locale);

  Future<void> loadSavedLanguage() async {
    emit(LanguageState(Locale(await loadLanguageCode())));
  }

  Future<void> setLanguage(AppLanguage language) async {
    await (await SharedPreferences.getInstance()).setString(_prefsKey, language.languageCode);

    emit(LanguageState(Locale(language.languageCode)));
  }

  @override
  void onChange(Change<LanguageState> change) {
    super.onChange(change);
    _applyLanguage(change.nextState.locale.languageCode);
  }

  /// Content titles and Firebase emails (password reset, email change) follow
  /// the app language.
  void _applyLanguage(String code) {
    ContentLanguage.code = code;
    try {
      FirebaseAuth.instance.setLanguageCode(code).catchError(
            (Object e) => debugPrint('Setting the Firebase language failed: $e'),
          );
    } catch (e) {
      // Firebase isn't initialized (tests).
      debugPrint('Setting the Firebase language failed: $e');
    }
  }
}

mixin Translation {
  AppLocalizations get tr => Get.the<LanguageCubit>().translation;
}
