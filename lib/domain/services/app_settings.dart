import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'interfaces/app_settings_view.dart';

class AppSettings with ChangeNotifier implements AppSettingsView {
  static final instance = AppSettings._();
  AppSettings._();

  static const _keyForThemeMode = 'ThemeMode';

  late SharedPreferences _storage;

  Future<void> initialize() async {
    _storage = await SharedPreferences.getInstance();
  }

  @override
  ThemeMode get themeMode =>
      ThemeMode.values.byName(_storage.getString(_keyForThemeMode) ?? 'system');

  Future<void> setThemeMode(ThemeMode value) async {
    await _storage.setString(_keyForThemeMode, value.name);
    notifyListeners();
  }
}
