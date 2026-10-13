import 'package:flutter/material.dart';

import '/domain/services/app_settings.dart';
import '/domain/services/language_cubit.dart';
import '/utils/app_theme.dart';
import '/utils/common_extensions.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';

class DisplayModeScreen extends StatefulWidget {
  const DisplayModeScreen({super.key});

  @override
  State<DisplayModeScreen> createState() => _DisplayModeScreenState();
}

class _DisplayModeScreenState extends State<DisplayModeScreen> with Translation {
  late ThemeMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = AppSettings.instance.themeMode;
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isDark) => AdaptiveAppBar(
          title: tr.displayMode,
          hasBottomLine: false,
        ),
        // bodyPadding: EdgeInsets.zero,
        body: (context, isDark) => RadioGroup<ThemeMode>(
          groupValue: _selectedMode,
          onChanged: (ThemeMode? newValue) async {
            if (newValue != null) {
              setState(() => _selectedMode = newValue);
              await AppSettings.instance.setThemeMode(newValue);
            }
          },
          child: ListView(
            children: <Widget>[
              _buildThemeModeRadioTile(
                title: tr.useDeviceSetting,
                value: ThemeMode.system,
              ),
              _buildThemeModeRadioTile(
                title: tr.lightMode,
                value: ThemeMode.light,
              ),
              _buildThemeModeRadioTile(
                title: tr.darkMode,
                value: ThemeMode.dark,
              ),
            ].interleaveWith(const SizedBox(height: 8)),
          ),
        ),
      );

  RadioListTile<ThemeMode> _buildThemeModeRadioTile({
    required String title,
    required ThemeMode value,
  }) =>
      RadioListTile<ThemeMode>(
        title: Text(title),
        value: value,
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
      );
}
