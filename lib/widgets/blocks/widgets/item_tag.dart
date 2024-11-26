import 'package:flutter/material.dart';

class ItemTag extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;

  const ItemTag({super.key, required this.text, this.icon, this.color});

  static const margin = 8.0; // 12
  static const padding = EdgeInsets.all(4); // 6
  static const borderRadius = 6.0; // 8

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final shadows = [
      Shadow(
        color: colors.onSurfaceVariant.withValues(alpha: 0.5),
        offset: const Offset(0.2, 0.5),
        blurRadius: 4,
      )
    ];
    return Positioned(
      bottom: margin,
      left: margin,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color:
              color != null ? Color.lerp(color, colors.surface, 0.3) : colors.secondary,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 10, color: colors.onSecondary, shadows: shadows),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 10,
                color: colors.onSecondary,
                fontWeight: FontWeight.w500,
                shadows: shadows,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
