import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final double size;
  final double iconSize;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.size,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: size,
        height: size,
        child: GestureDetector(
          onTap: onPressed,
          child: Material(
            elevation: 0,
            shape: CircleBorder(),
            clipBehavior: Clip.antiAlias,
            color: Colors.transparent,
            child: Ink(
                decoration: ShapeDecoration(
                  color: backgroundColor,
                  shape: CircleBorder(),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: Colors.white,
                  ),
                )),
          ),
        ));
  }
}
