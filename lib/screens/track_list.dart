import 'package:flutter/material.dart';
import '/domain/models/block_item/audio_track.dart';

import '/domain/services/audio_panel_manager.dart';
import '/utils/get.dart';
import '/utils/global_functions.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/track_list_item.dart';

class TrackListScreen extends StatefulWidget {
  final String heading;
  final List<AudioTrack> list;

  const TrackListScreen({
    super.key,
    required this.heading,
    required this.list,
  });

  @override
  State<TrackListScreen> createState() => _TrackListScreenState();
}

class _TrackListScreenState extends State<TrackListScreen> {
  final _audioPanelManager = Get.the<AudioPanelManager>();

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isMobile) => AdaptiveAppBar(
          title: widget.heading,
        ),
        body: (context, isMobile) => GridView.builder(
          itemCount: widget.list.length,
          padding: EdgeInsets.only(bottom: 165),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final track = widget.list[index];
            return TrackListItemSmall(
              imageUrl: track.thumbnail,
              mp3Name: track.title,
              mp3Category: 'ERROR!', // TODO: FIX
              // mp3Category: track.categories.firstOrNull?.categoryName ?? '',
              mp3Duration: track.durationString,
              tap: () {
                playTrack(track);
                _audioPanelManager.maximizeAndPlay(false);
              },
            );
          },
        ),
      );
}
