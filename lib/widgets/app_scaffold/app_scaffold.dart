import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.resizeToAvoidBottomInset,
    this.bottomNavigationBar,
    this.bodyPadding = const EdgeInsets.fromLTRB(16, 0, 16, 0),
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final bool? resizeToAvoidBottomInset;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry bodyPadding;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: appBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: Stack(
          children: [
            Padding(
              padding: bodyPadding,
              child: body,
            ),
            if (bottomNavigationBar != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: bottomNavigationBar!,
              ),
          ],
        ),
      );
}
