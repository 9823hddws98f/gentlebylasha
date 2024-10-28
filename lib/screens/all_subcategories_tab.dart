import 'package:flutter/material.dart';
import 'package:sleeptales/widgets/mp3_list_item.dart';

import '/screens/track_list.dart';
import '/utils/colors.dart';
import '/utils/firestore_helper.dart';
import '/utils/global_functions.dart';
import '/widgets/tracklist_horizontal_widget.dart';
import '../domain/models/audiofile_model.dart';
import '../domain/models/category_block.dart';
import '../domain/models/collection_model.dart';
import '../domain/models/sub_categories.dart';

class AllSubCategoriesTab extends StatefulWidget {
  final List<SubCategory> subCategories;
  final CategoryBlock category;
  final Function panelFunction;

  const AllSubCategoriesTab({
    super.key,
    required this.subCategories,
    required this.category,
    required this.panelFunction,
  });

  @override
  State<AllSubCategoriesTab> createState() => _AllSubCategoriesTab();
}

class _AllSubCategoriesTab extends State<AllSubCategoriesTab> {
  bool newworthyIsLoading = true;
  bool recentIsLoading = true;
  bool popularIsLoading = true;
  bool collectionsIsLoading = true;
  List<AudioTrack> audioList1 = [];
  List<AudioTrack> recentlyPlayed = [];
  List<AudioTrack> popularCat = [];
  List<Collection> topCollection = [];
  @override
  void initState() {
    super.initState();
    fetchRecentlyPlayedTracks(widget.category.id);
    fetchTopCollections(widget.category.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                if (recentIsLoading || recentlyPlayed.isNotEmpty) ...[
                  Padding(
                      padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                      child: Row(
                        children: [
                          Text(
                            "Recently played",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          if (recentlyPlayed.isNotEmpty)
                            TextButton(
                                onPressed: () {
                                  pushName(
                                      context,
                                      TrackListScreen(
                                        heading: "Recently Played",
                                        list: recentlyPlayed,
                                      ));
                                },
                                child: Text(
                                  "See all",
                                  style: TextStyle(color: blueAccentColor, fontSize: 16),
                                ))
                        ],
                      )),
                  recentlyPlayed.isEmpty
                      ? _buildShimmerListViewHeight()
                      : TrackListHorizontal(
                          trackList: recentlyPlayed,
                          musicList: widget.category.name == 'Music',
                        ),
                ],

                if (!collectionsIsLoading && topCollection.isNotEmpty) ...[
                  SizedBox(
                    child: ListView.separated(
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.zero,
                      itemCount: topCollection.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(width: 0);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                                padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                                child: Row(
                                  children: [
                                    Text(
                                      topCollection[index].collectionTitle,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
                                    TextButton(
                                        onPressed: () {
                                          pushName(
                                              context,
                                              TrackListScreen(
                                                heading:
                                                    topCollection[index].collectionTitle,
                                                list:
                                                    topCollection[index].collectionTracks,
                                              ));
                                        },
                                        child: Text(
                                          "See all",
                                          style: TextStyle(
                                              color: blueAccentColor, fontSize: 16),
                                        ))
                                  ],
                                )),
                            topCollection[index].collectionTracks.isEmpty
                                ? _buildShimmerListViewHeight()
                                : TrackListHorizontal(
                                    trackList: topCollection[index].collectionTracks,
                                    musicList: widget.category.name == 'Music',
                                  ),
                          ],
                        );
                      },
                    ),
                  )
                ] else ...[
                  _buildShimmerListViewFullWidget(),
                ],
                // Heading and horizontal list view of cards

                SizedBox(
                  height: 165,
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> getFirtList(String cat) async {
    audioList1 = await getNewAndWorthyByCategory(cat);
    newworthyIsLoading = false;
    setState(() {});
  }

  void fetchPopularTracks(String cat) async {
    popularCat = await getPopularTracksByCategory(cat);
    popularIsLoading = false;
    setState(() {});
  }

  Widget _buildShimmerListViewFullWidget() {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
            child: Row(
              children: [
                Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      color: shimmerBaseColor,
                      borderRadius: BorderRadius.circular(20),
                    )),
                Spacer(),
                Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      color: shimmerBaseColor,
                      borderRadius: BorderRadius.circular(20),
                    ))
              ],
            )),
        SizedBox(
          height: 231,
          child: ListView.separated(
            padding: EdgeInsets.only(left: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(width: 16);
            },
            itemBuilder: (BuildContext context, int index) {
              return Mp3ListItem.shimmer();
            },
          ),
        )
      ],
    );
  }

  Widget _buildShimmerListViewHeight() {
    return SizedBox(
      height: 231,
      child: ListView.separated(
        padding: EdgeInsets.only(left: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(width: 16);
        },
        itemBuilder: (BuildContext context, int index) {
          return Mp3ListItem.shimmer();
        },
      ),
    );
  }

  void fetchRecentlyPlayedTracks(String cat) async {
    recentlyPlayed = await getRecentlyPlayedTracksByCategory(cat);
    recentIsLoading = false;
    setState(() {});
  }

  void fetchTopCollections(String cat) async {
    topCollection = await getTopCollections(cat);
    collectionsIsLoading = false;
    setState(() {});
  }
}
