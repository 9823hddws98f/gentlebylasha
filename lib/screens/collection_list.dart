import 'package:flutter/material.dart';

import '/screens/track_list.dart';
import '/widgets/collection_item_grid.dart';
import '../models/collection_model.dart';
import '../utils/global_functions.dart';
import '../widgets/shimmerwidgets/shimmer_mp3_card_list_item_small.dart';
import '../widgets/topbar_widget.dart';

class CollectionListScreen extends StatefulWidget {
  final String heading;
  final List<Collection> list;
  final Function panelFunction;

  const CollectionListScreen({
    super.key,
    required this.heading,
    required this.list,
    required this.panelFunction,
  });

  @override
  State<CollectionListScreen> createState() => _CollectionListScreenState();
}

class _CollectionListScreenState extends State<CollectionListScreen> {
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
                                    childAspectRatio: 1.22),
                                itemBuilder: (BuildContext context, int index) {
                                  return CollectionItemGrid(
                                    imageUrl: widget.list[index].collectionThumbnail,
                                    mp3Name: widget.list[index].collectionTitle,
                                    mp3Category: widget
                                        .list[index].collectionCategory[0].categoryName,
                                    tap: () {
                                      pushName(
                                          context,
                                          TrackListScreen(
                                            heading: widget.list[index].collectionTitle,
                                            list: widget.list[index].collectionTracks,
                                            panelFunction: widget.panelFunction,
                                          ));
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
