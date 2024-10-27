import 'package:flutter/material.dart';

import '/domain/services/audio_panel_manager.dart';
import '/utils/get.dart';
import '/widgets/track_list_item.dart';
import '../domain/models/audiofile_model.dart';
import '../utils/global_functions.dart';
import '../widgets/shimmerwidgets/shimmer_mp3_card_list_item_small.dart';
import '../widgets/topbar_widget.dart';

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TopBar(
                        heading: widget.heading,
                        onPress: () {
                          Navigator.pop(context);
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    (widget.list.isNotEmpty)
                        ? Expanded(
                            child: SingleChildScrollView(
                            padding: EdgeInsets.only(bottom: 165),
                            child: GridView.builder(
                                itemCount: widget.list.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.81),
                                itemBuilder: (BuildContext context, int index) {
                                  return TrackListItemSmall(
                                    imageUrl: widget.list[index].thumbnail,
                                    mp3Name: widget.list[index].title,
                                    mp3Category:
                                        widget.list[index].categories[0].categoryName,
                                    mp3Duration: widget.list[index].length,
                                    tap: () {
                                      playTrack(widget.list[index]);
                                      _audioPanelManager.showPanel(false);
                                    },
                                  );
                                }),
                          ))
                        : _buildShimmerListView(),
                  ],
                ))),
      ),
    );
  }

  Widget _buildShimmerListView() {
    return Expanded(
        child: SingleChildScrollView(
      child: GridView.builder(
          itemCount: widget.list.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.81),
          itemBuilder: (BuildContext context, int index) {
            return Mp3ListItemShimmerSmall();
          }),
    ));
  }
}
