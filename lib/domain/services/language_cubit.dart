import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/main.dart';
import '/utils/get.dart';

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
  static final defaultLanguage = AppLanguage.english;

  LanguageCubit._() : super(LanguageState(Locale(defaultLanguage.languageCode))) {
    loadSavedLanguage();
  }

  AppLocalizations get translation =>
      AppLocalizations.of(MyApp.navigatorKey.currentContext!)!;

  Future<void> loadSavedLanguage() async {
    final code = (await SharedPreferences.getInstance()).getString(_prefsKey) ??
        defaultLanguage.languageCode;

    emit(LanguageState(Locale(code)));
  }

  Future<void> setLanguage(AppLanguage language) async {
    await (await SharedPreferences.getInstance())
        .setString(_prefsKey, language.languageCode);

    emit(LanguageState(Locale(language.languageCode)));
  }
}

mixin Translation {
  AppLocalizations get tr => Get.the<LanguageCubit>().translation;
}
