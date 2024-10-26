import 'package:flutter/material.dart';

import '/utils/common_extensions.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.resizeToAvoidBottomInset,
    this.bodyPadding = const EdgeInsets.fromLTRB(16, 0, 16, 0),
  });

  final PreferredSizeWidget? Function(BuildContext context, bool isMobile)? appBar;
  final Widget Function(BuildContext context, bool isMobile) body;
  final bool? resizeToAvoidBottomInset;
  final EdgeInsetsGeometry bodyPadding;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return Scaffold(
      appBar: appBar?.call(context, isMobile),
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Padding(
        padding: bodyPadding,
        child: body(context, isMobile),
      ),
    );
  }
}
