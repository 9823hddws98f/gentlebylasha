import 'package:flutter/material.dart';

import '/main.dart';
import '/utils/app_theme.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.resizeToAvoidBottomInset,
    this.bodyPadding = const EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
  });

  final Widget? Function(BuildContext context, bool isMobile)? appBar;
  final Widget Function(BuildContext context, bool isMobile) body;
  final bool? resizeToAvoidBottomInset;
  final EdgeInsetsGeometry bodyPadding;

  @override
  Widget build(BuildContext context) {
    // Screens read their texts through `tr` without a BuildContext; depending on
    // the locale here rebuilds every screen (title and body) after a language switch.
    Localizations.localeOf(context);
    // MyApp.isMobile reads the navigator's context; depend on the size here so a
    // resized browser window switches between the phone and desktop layout.
    MediaQuery.sizeOf(context);
    final isMobile = MyApp.isMobile;
    return Scaffold(
      appBar: appBar?.call(context, isMobile) as PreferredSizeWidget?,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Padding(
        padding: bodyPadding,
        child: body(context, isMobile),
      ),
    );
  }
}
