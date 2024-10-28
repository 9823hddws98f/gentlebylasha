import 'package:flutter/material.dart';
import 'package:sleeptales/widgets/app_scaffold/adaptive_app_bar.dart';
import 'package:sleeptales/widgets/app_scaffold/app_scaffold.dart';

import '/domain/services/audio_panel_manager.dart';
import '/utils/get.dart';
import '/widgets/track_list_item.dart';
import '../domain/models/audiofile_model.dart';
import '../utils/global_functions.dart';

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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final track = widget.list[index];
            return TrackListItemSmall(
              imageUrl: track.thumbnail,
              mp3Name: track.title,
              mp3Category: track.categories.firstOrNull?.categoryName ?? '',
              mp3Duration: track.length,
              tap: () {
                playTrack(track);
                _audioPanelManager.maximize(false);
              },
            );
          },
        ),
      );
}
