import 'package:flutter/material.dart';

class ItemTag extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;

  const ItemTag({super.key, required this.text, this.icon, this.color});

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
      bottom: 8, // 12
      left: 8, // 12
      child: Container(
        padding: const EdgeInsets.all(4), // 6
        decoration: BoxDecoration(
          color:
              color != null ? Color.lerp(color, colors.surface, 0.3) : colors.secondary,
          borderRadius: BorderRadius.circular(6), // 8
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
