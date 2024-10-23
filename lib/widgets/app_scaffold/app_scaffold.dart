import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.resizeToAvoidBottomInset,
    this.modalHeight,
  });

  factory AppScaffold.modal({required Widget body, required double height}) =>
      AppScaffold(
        resizeToAvoidBottomInset: false,
        modalHeight: height,
        body: body,
      );

  final Widget body;
  final bool? resizeToAvoidBottomInset;
  final double? modalHeight;

  bool get isModal => modalHeight != null;

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: isModal ? Colors.transparent : null,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: body,
      ),
    );
    if (isModal == true) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: modalHeight,
          child: scaffold,
        ),
      );
    }
    return scaffold;
  }
}
