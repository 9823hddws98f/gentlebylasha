import 'package:flutter/material.dart';

import '/domain/blocs/user/app_user.dart';
import '/domain/models/audiofile_model.dart';
import '/domain/models/block.dart';
import '/domain/models/collection_model.dart';
import '/domain/models/sub_categories.dart';
import '/screens/playlist_screen.dart';
import '/screens/track_list.dart';
import '/utils/colors.dart';
import '/utils/firestore_helper.dart';
import '/utils/global_functions.dart';
import '/widgets/shimmerwidgets/shimmer_mp3_card_list_item_height.dart';
import '/widgets/tracklist_horizontal_widget.dart';

class SubCategoriesTab extends StatefulWidget {
  final SubCategory subCategory;
  final Function panelFunction;
  const SubCategoriesTab(this.subCategory, this.panelFunction, {super.key});
  @override
  State<SubCategoriesTab> createState() => _SubCategoriesTab();
}

class _SubCategoriesTab extends State<SubCategoriesTab> {
  bool newworthyIsLoading = true;
  bool recentIsLoading = true;
  bool popularIsLoading = true;
  bool collectionsIsLoading = true;
  List<AudioTrack> audioList1 = [];
  List<AudioTrack> recentlyPlayed = [];
  List<AudioTrack> popularCat = [];
  List<Collection> topCollection = [];
  List<Block> blockList = [];
  final Map<String, List<AudioTrack>> _blockTracks = {};
  String nickName = "";
  @override
  void initState() {
    super.initState();
    getPageBlocks();

    //getTopCollectionsSubcateory(widget.subCategory.subCategoryID);
  }

  Future<void> getPageBlocks() async {
    blockList = await getBlockOfSubCategory(widget.subCategory.subCategoryID);
    setState(() {});
  }

  // Function to fetch tracks for a block and update the state
  Future<void> fetchAndSetTracks(String blockId) async {
    final tracks = await fetchTracksForBlock(blockId);
    //debugPrint("tracks length ${tracks.length}");
    setState(() {
      _blockTracks[blockId] = tracks;
    });
    // debugPrint(tracks.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              blockList.isEmpty
                  ? _buildShimmerListViewHeightWithTitle()
                  : ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 0),
                      itemCount: blockList.length,
                      itemBuilder: (context, index) {
                        final block = blockList[index];
                        final blockId = block.id;
                        // Check if tracks for this block are already fetched
                        final tracks = _blockTracks[blockId];

                        if (tracks == null) {
                          fetchAndSetTracks(blockId);
                          return Column(
                            children: [
                              Padding(
                                  padding: EdgeInsets.fromLTRB(14, 14, 14, 14),
                                  child: Row(children: [
                                    Text(
                                      block.title,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ])),
                              _buildShimmerListViewHeight()
                            ],
                          ); // or a loading indicator
                        } else if (tracks.isEmpty) {
                          // Handle the case when there are no tracks
                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(14, 14, 14, 14),
                                child: Row(
                                  children: [
                                    Text(
                                      block.title,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text("No tracks available")
                            ],
                          );
                        } else {
                          // Display the list of tracks for this block
                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(14, 14, 14, 14),
                                child: Row(
                                  children: [
                                    Text(
                                      block.title,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
                                    if (tracks.isNotEmpty)
                                      TextButton(
                                          onPressed: () {
                                            if (block.blockType == "series") {
                                              pushName(
                                                context,
                                                PlayListScreen(
                                                  list: tracks,
                                                  block: block,
                                                ),
                                              );
                                            } else {
                                              pushName(
                                                context,
                                                TrackListScreen(
                                                  heading: block.title,
                                                  list: tracks,
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            "See all",
                                            style: TextStyle(
                                                color: seeAllColor, fontSize: 16),
                                          ))
                                  ],
                                ),
                              ),
                              tracks.isEmpty
                                  ? _buildShimmerListViewHeight()
                                  : SizedBox(
                                      height: 231,
                                      child: TrackListHorizontal(
                                        onTap: () {},
                                        trackList: tracks,
                                        musicList:
                                            block.blockType == "series" ? true : false,
                                      ),
                                    ),
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Divider(
                                  height: 1,
                                  color: dividerColor,
                                ),
                              )
                            ],
                          );
                        }
                      },
                    ),
              // if(!collectionsIsLoading && topCollection.isNotEmpty)...[
              //   SizedBox(
              //     child:ListView.separated(
              //       scrollDirection: Axis.vertical,
              //       padding: EdgeInsets.zero,
              //       itemCount: topCollection.length,
              //       physics: NeverScrollableScrollPhysics(),
              //       shrinkWrap: true,
              //       separatorBuilder: (BuildContext context, int index) {
              //         return SizedBox(width: 0);
              //       },
              //       itemBuilder: (BuildContext context, int index) {
              //         return Column(
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             Padding(
              //                 padding: EdgeInsets.fromLTRB(16, 32,16,16),
              //                 child: Row(
              //                   children: [
              //                     Text(
              //                       topCollection[index].collectionTitle,
              //                       style: TextStyle(
              //                         fontSize: 22,
              //                         fontWeight: FontWeight.bold,
              //                       ),
              //                     ),
              //
              //                     Spacer(),
              //                     TextButton(onPressed: (){
              //                       pushName(context, TrackListScreen(heading: topCollection[index].collectionTitle,list:topCollection[index].collectionTracks,panelFunction: widget.panelFunction,));
              //
              //                     }, child:Text("See all",style: TextStyle(color: blueAccentColor,fontSize: 16),))
              //                   ],
              //
              //                 )
              //             ),
              //             topCollection[index].collectionTracks.isEmpty
              //                 ? _buildShimmerListViewHeight()
              //                 : SizedBox(
              //                 height: 231,
              //                 child: TrackListHorizontal(tap: (){
              //
              //                 },audiList: topCollection[index].collectionTracks,musicList:widget.subCategory.name == "Music"?true:false,panelFunction: widget.panelFunction,)
              //             ),
              //           ],
              //         );
              //       },
              //     ),
              //   )
              //
              // ]else...[
              //   _buildShimmerListViewFullWidget(),
              // ],
            ],
          ),
        ));
  }

  void fetchPopularTracks(String cat) async {
    popularCat = await getPopularTracksByCategory(cat);
    popularIsLoading = false;
    setState(() {});
  }

  Widget _buildShimmerListViewHeightWithTitle() {
    return Column(
      children: [
        // Heading and horizontal list view of cards
        Padding(
            padding: EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                Text(
                  "       ",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                TextButton(
                    onPressed: () {},
                    child: Text(
                      "    ",
                      style: TextStyle(color: blueAccentColor, fontSize: 16),
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
              return Mp3ListItemShimmerHeight();
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
          return Mp3ListItemShimmerHeight();
        },
      ),
    );
  }

  Widget _buildShimmerListViewFullWidget() {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.fromLTRB(16, 32, 16, 20),
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
              return Mp3ListItemShimmerHeight();
            },
          ),
        )
      ],
    );
  }

  void setFirstName() async {
    AppUser user = await getUser();
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

  void getTopCollectionsSubcateory(String cat) async {
    topCollection = await fetchCollectionsBySubcategory(cat);
    collectionsIsLoading = false;
    setState(() {});
  }
}
