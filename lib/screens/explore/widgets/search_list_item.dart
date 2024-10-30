import 'package:flutter/material.dart';
import 'package:sleeptales/widgets/app_image.dart';

import '/utils/app_theme.dart';

class SearchListItem extends StatelessWidget {
  const SearchListItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.category,
    required this.duration,
    required this.speaker,
    required this.onPress,
  });

  final String imageUrl;
  final String name;
  final String category;
  final String duration;
  final String speaker;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onPress,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sidePadding,
        vertical: 4,
      ),
      leading: ClipRRect(
        borderRadius: AppTheme.smallBorderRadius,
        child: AppImage(
          imageUrl: imageUrl,
          height: 50,
          width: 50,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => const Icon(Icons.error),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: [category, speaker].any((s) => s.isNotEmpty)
          ? Text(
              [category, speaker].where((s) => s.isNotEmpty).join(' • '),
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Text(
        '$duration min',
        style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
      ),
    );
  }
}