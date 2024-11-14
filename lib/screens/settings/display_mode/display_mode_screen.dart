import 'package:flutter/material.dart';

import '/domain/services/app_settings.dart';
import '/utils/app_theme.dart';
import '/utils/common_extensions.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';

class DisplayModeScreen extends StatefulWidget {
  const DisplayModeScreen({super.key});

  @override
  State<DisplayModeScreen> createState() => _DisplayModeScreenState();
}

class _DisplayModeScreenState extends State<DisplayModeScreen> {
  late ThemeMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = AppSettings.instance.themeMode;
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isDark) => AdaptiveAppBar(
          title: 'Display Mode',
          hasBottomLine: false,
        ),
        // bodyPadding: EdgeInsets.zero,
        body: (context, isDark) => ListView(
          children: <Widget>[
            _buildThemeModeRadioTile(
              title: 'Use Device Setting',
              value: ThemeMode.system,
            ),
            _buildThemeModeRadioTile(
              title: 'Light Mode',
              value: ThemeMode.light,
            ),
            _buildThemeModeRadioTile(
              title: 'Dark Mode',
              value: ThemeMode.dark,
            ),
          ].interleaveWith(const SizedBox(height: 8)),
        ),
      );

  RadioListTile<ThemeMode> _buildThemeModeRadioTile({
    required String title,
    required ThemeMode value,
  }) =>
      RadioListTile<ThemeMode>(
        title: Text(title),
        value: value,
        groupValue: _selectedMode,
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
        onChanged: (ThemeMode? newValue) async {
          if (newValue != null) {
            setState(() => _selectedMode = newValue);
            await AppSettings.instance.setThemeMode(newValue);
          }
        },
      );
}
