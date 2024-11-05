import 'package:flutter/material.dart';

import '/domain/models/block_item/audio_track.dart';
import '/domain/services/audio_panel_manager.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/utils/global_functions.dart';
import '/widgets/app_image.dart';

class SearchListItem extends StatelessWidget {
  SearchListItem(this.track, {super.key});

  final AudioTrack track;

  final _audioPanelManager = Get.the<AudioPanelManager>();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      onTap: () {
        playTrack(track);
        _audioPanelManager.maximize(false);
      },
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sidePadding,
        vertical: 4,
      ),
      leading: ClipRRect(
        borderRadius: AppTheme.smallBorderRadius,
        child: AppImage(
          imageUrl: track.thumbnail,
          height: 50,
          width: 50,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => const Icon(Icons.error),
        ),
      ),
      title: Text(
        track.title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '${track.duration} min',
        style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
      ),
    );
  }
}
