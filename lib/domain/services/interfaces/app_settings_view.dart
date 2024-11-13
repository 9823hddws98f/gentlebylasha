import 'package:flutter/material.dart';

abstract interface class AppSettingsView with ChangeNotifier {
  ThemeMode get themeMode;
}
