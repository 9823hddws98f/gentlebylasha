import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class SharedAxisSwitcher extends StatelessWidget {
  const SharedAxisSwitcher({
    super.key,
    this.transitionType = SharedAxisTransitionType.horizontal,
    this.disableFillColor = false,
    this.reverse = false,
    required this.child,
  });

  final SharedAxisTransitionType transitionType;
  final bool disableFillColor;
  final Widget child;
  final bool reverse;

  @override
  Widget build(BuildContext context) => PageTransitionSwitcher(
        reverse: reverse,
        child: child,
        transitionBuilder: (
          Widget child,
          Animation<double> primaryAnimation,
          Animation<double> secondaryAnimation,
        ) =>
            SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          fillColor: disableFillColor ? Colors.transparent : null,
          child: child,
        ),
      );
}
