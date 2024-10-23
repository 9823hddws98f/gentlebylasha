import 'package:flutter/material.dart';

import '/models/user_model.dart';
import '/screens/track_list.dart';
import '/utils/colors.dart';
import '/utils/firestore_helper.dart';
import '/utils/global_functions.dart';
import '/widgets/tracklist_horizontal_widget.dart';
import '/widgets/width_tracklist_horizontal_widget.dart';
import '../models/audiofile_model.dart';
import '../models/category_model.dart';
import '../models/collection_model.dart';
import '../widgets/shimmerwidgets/shimmer_mp3_card_list_item_height.dart';
import '../widgets/shimmerwidgets/shimmer_mp3_card_list_item_small.dart';
import '../widgets/shimmerwidgets/shimmer_mp3_card_list_item_width.dart';

class TabsScreen extends StatefulWidget {
  final Categories category;
  final Function panelFunction;
  const TabsScreen(this.category, this.panelFunction, {super.key});
  @override
  State<TabsScreen> createState() => _TabsScreen();
}

class _TabsScreen extends State<TabsScreen> {
  bool newworthyIsLoading = true;
  bool recentIsLoading = true;
  bool popularIsLoading = true;
  bool collectionsIsLoading = true;
  List<AudioTrack> audioList1 = [];
  List<AudioTrack> recentlyPlayed = [];
  List<AudioTrack> popularCat = [];
  List<Collection> topCollection = [];
  String nickName = "";
  @override
  void initState() {
    super.initState();
    // Simulate data loading delay
    //setFirstName();
    getFirtList(widget.category.id);
    fetchRecentlyPlayedTracks(widget.category.id);
    fetchPopularTracks(widget.category.id);
    fetchTopCollections(widget.category.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            gradientColorOne,
            gradientColorTwo,
          ],
          stops: [0.0926, 1.0],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (!newworthyIsLoading && audioList1.isNotEmpty) ...[
              Padding(
                  padding: EdgeInsets.fromLTRB(16, 15, 16, 16),
                  child: Row(
                    children: [
                      Text(
                        "New & Worthy",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      if (audioList1.isNotEmpty)
                        TextButton(
                            onPressed: () {
                              pushName(
                                  context,
                                  TrackListScreen(
                                    heading: "New & Worthy",
                                    list: audioList1,
                                    panelFunction: widget.panelFunction,
                                  ));
                            },
                            child: Text(
                              "See all",
                              style: TextStyle(color: blueAccentColor, fontSize: 16),
                            ))
                    ],
                  )),
              audioList1.isEmpty
                  ? _buildShimmerListViewWidth()
                  : SizedBox(
                      height: 231,
                      child: WidthTrackListHorizontal(
                        audiList: audioList1,
                        tap: () {},
                        musicList: false,
                        panelFunction: widget.panelFunction,
                      ),
                    ),
            ],
            // Heading and horizontal list view of cards
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
                                    panelFunction: widget.panelFunction,
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
                  : SizedBox(
                      height: 231,
                      child: TrackListHorizontal(
                        tap: () {},
                        audiList: recentlyPlayed,
                        musicList: widget.category.categoryName == "Music" ? true : false,
                        panelFunction: widget.panelFunction,
                      )

                      // ListView.separated(
                      //   padding: EdgeInsets.only(left:16),
                      //   scrollDirection: Axis.horizontal,
                      //   itemCount: recentlyPlayed.length < 10?recentlyPlayed.length:10,
                      //   separatorBuilder: (BuildContext context, int index) {
                      //     return SizedBox(width: 16);
                      //   },
                      //   itemBuilder: (BuildContext context, int index) {
                      //     return Mp3Item(
                      //       imageUrl: recentlyPlayed[index].imageBackground,
                      //       mp3Name: recentlyPlayed[index].title,
                      //       mp3Category: recentlyPlayed[index].categories[0],
                      //       mp3Duration: recentlyPlayed[index].length,
                      //       tap: (){
                      //
                      //         playTrack(recentlyPlayed[index]);
                      //         Navigator.of(context).push( SlideFromBottomPageRoute(page: MusicPlayerScreen( audioFile: recentlyPlayed[index],playList: false)));
                      //
                      //       },
                      //     );
                      //   },
                      // ),
                      ),
            ],

            if (popularIsLoading || popularCat.isNotEmpty) ...[
              // Heading and horizontal list view of cards
              Padding(
                  padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                  child: Row(
                    children: [
                      Text(
                        "Popular ${widget.category.categoryName}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      if (popularCat.isNotEmpty)
                        TextButton(
                            onPressed: () {
                              pushName(
                                  context,
                                  TrackListScreen(
                                    heading: "Popular ${widget.category.categoryName}",
                                    list: popularCat,
                                    panelFunction: widget.panelFunction,
                                  ));
                            },
                            child: Text(
                              "See all",
                              style: TextStyle(color: blueAccentColor, fontSize: 16),
                            ))
                    ],
                  )),
              popularCat.isEmpty
                  ? _buildShimmerListViewHeight()
                  : SizedBox(
                      height: 231,
                      child: TrackListHorizontal(
                        tap: () {},
                        audiList: popularCat,
                        musicList: widget.category.categoryName == "Music" ? true : false,
                        panelFunction: widget.panelFunction,
                      )),
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
                                            heading: topCollection[index].collectionTitle,
                                            list: topCollection[index].collectionTracks,
                                            panelFunction: widget.panelFunction,
                                          ));
                                    },
                                    child: Text(
                                      "See all",
                                      style:
                                          TextStyle(color: blueAccentColor, fontSize: 16),
                                    ))
                              ],
                            )),
                        topCollection[index].collectionTracks.isEmpty
                            ? _buildShimmerListViewHeight()
                            : SizedBox(
                                height: 231,
                                child: TrackListHorizontal(
                                    tap: () {},
                                    audiList: topCollection[index].collectionTracks,
                                    musicList: widget.category.categoryName == "Music"
                                        ? true
                                        : false,
                                    panelFunction: widget.panelFunction),
                              ),
                      ],
                    );
                  },
                ),
              )
            ] else ...[
              if (collectionsIsLoading) CircularProgressIndicator()
            ],
            // Heading and horizontal list view of cards

            SizedBox(
              height: 100,
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

  Widget _buildShimmerListViewWidth() {
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
          return Mp3ListItemShimmer();
        },
      ),
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
          return Mp3ListItemShimmerHeight();
        },
      ),
    );
  }

  Widget _buildShimmerListViewSmall() {
    return SizedBox(
      height: 133,
      child: ListView.separated(
        padding: EdgeInsets.only(left: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(width: 16);
        },
        itemBuilder: (BuildContext context, int index) {
          return Mp3ListItemShimmerSmall();
        },
      ),
    );
  }

  void setFirstName() async {
    UserModel user = await getUser();
    String? fullName = user.name;
    List<String> words = fullName!.split(' ');
    setState(() {
      nickName = words.first;
    });
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
