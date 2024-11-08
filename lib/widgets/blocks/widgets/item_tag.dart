import 'package:flutter/material.dart';

class ItemTag extends StatelessWidget {
  final String text;
  final IconData? icon;

  const ItemTag({super.key, required this.text, this.icon});

  @override
  Widget build(BuildContext context) => Positioned(
        bottom: 12,
        left: 12,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 10),
                const SizedBox(width: 4),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
}
