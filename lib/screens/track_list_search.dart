import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/widgets/track_list_item.dart';
import '../domain/models/audiofile_model.dart';
import '../domain/models/category_model.dart';
import '../domain/services/service_locator.dart';
import '../page_manager.dart';
import '../utils/global_functions.dart';
import '../widgets/shimmerwidgets/shimmer_mp3_card_tracklist_item.dart';
import '../widgets/topbar_widget.dart';

class TrackListSearchScreen extends StatefulWidget {
  final Categories category;
  final Function panelFunction;
  const TrackListSearchScreen(
      {super.key, required this.category, required this.panelFunction});
  @override
  State<TrackListSearchScreen> createState() => _TrackListSearchScreenState();
}

class _TrackListSearchScreenState extends State<TrackListSearchScreen> {
  List<AudioTrack> list = [];

  @override
  void initState() {
    super.initState();
    getTrackList(widget.category.id);
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
                        heading: widget.category.categoryName,
                        onPress: () {
                          Navigator.pop(context);
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    (list.isNotEmpty)
                        ? Expanded(
                            child: SingleChildScrollView(
                            padding: EdgeInsets.only(bottom: 165),
                            child: GridView.builder(
                                itemCount: list.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.81),
                                itemBuilder: (BuildContext context, int index) {
                                  return TrackListItemSmall(
                                    imageUrl: list[index].thumbnail,
                                    mp3Name: list[index].title,
                                    mp3Category: list[index].categories[0].categoryName,
                                    mp3Duration: list[index].length,
                                    tap: () {
                                      if (widget.category.categoryName == "Music") {
                                        getIt<PageManager>().loadPlaylist(list, index);
                                        widget.panelFunction(false);
                                      } else {
                                        playTrack(list[index]);
                                        widget.panelFunction(false);
                                      }
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
          itemCount: 10,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.81),
          itemBuilder: (BuildContext context, int index) {
            return ShimmerTrackListItemSmall();
          }),
    ));
  }

  Future<void> getTrackList(String search) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Tracks')
        .where('categories', arrayContains: search)
        .get();

    if (snapshot.size > 0) {
      list = snapshot.docs.map((doc) {
        return AudioTrack.fromFirestore(doc);
      }).toList();
      setState(() {});
    }
  }
}
