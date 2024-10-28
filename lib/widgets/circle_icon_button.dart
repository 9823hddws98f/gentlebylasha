import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final double? size;
  final double? iconSize;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.size,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: iconSize,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        fixedSize: size != null ? Size(size!, size!) : null,
      ),
    );
  }
}
