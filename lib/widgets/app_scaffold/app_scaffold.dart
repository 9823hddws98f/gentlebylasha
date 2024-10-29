import 'package:flutter/material.dart';
import 'package:sleeptales/main.dart';

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
