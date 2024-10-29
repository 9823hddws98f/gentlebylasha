import 'package:flutter/material.dart';

import '/domain/services/language_constants.dart';
import '/languages.dart';
import '/main.dart';
import '/utils/get.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';

class ChangeLanguageScreen extends StatefulWidget {
  final String? email;
  const ChangeLanguageScreen({super.key, this.email});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreen();
}

class _ChangeLanguageScreen extends State<ChangeLanguageScreen> with Translation {
  final _translationService = Get.the<TranslationService>();
  // default selection
  int languageIndex = 0;

  Future<void> _handleLanguageChange(int index) async {
    final locale = await _translationService
        .setLocale(Language.languageList().elementAt(index).languageCode);

    if (!mounted) return;
    MyApp.setLocale(context, locale);

    setState(() => languageIndex = index);
  }

  Future<void> getCurrentLanguageIndex() async {
    String languageCode = await _translationService.getLanguageCode();
    if (languageCode == "de") {
      languageIndex = 1;
    } else {
      languageIndex = 0;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getCurrentLanguageIndex();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isMobile) => AdaptiveAppBar(
          title: tr.changeLanguage,
        ),
        bodyPadding: EdgeInsets.zero,
        body: (context, isMobile) => ListView(
          children: [
            ListTile(
              title: const Text('English'),
              trailing: languageIndex == 0 ? const Icon(Icons.check) : null,
              onTap: () => _handleLanguageChange(0),
            ),
            ListTile(
              title: const Text('Dutch'),
              trailing: languageIndex == 1 ? const Icon(Icons.check) : null,
              onTap: () => _handleLanguageChange(1),
            ),
          ],
        ),
      );
}
