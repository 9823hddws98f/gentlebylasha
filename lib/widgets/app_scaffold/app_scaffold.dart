import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.resizeToAvoidBottomInset,
    this.bottomNavigationBar,
  });

  final Widget body;
  final bool? resizeToAvoidBottomInset;
  final Widget? bottomNavigationBar;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
