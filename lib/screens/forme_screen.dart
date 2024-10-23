import 'package:flutter/material.dart';

import '/language_constants.dart';
import '/models/user_model.dart';
import '/screens/playlist_screen.dart';
import '/screens/track_list.dart';
import '/utils/colors.dart';
import '/utils/firestore_helper.dart';
import '/utils/global_functions.dart';
import '/widgets/shimmerwidgets/shimmer_tab_layout.dart';
import '/widgets/width_tracklist_horizontal_widget.dart';
import '../helper/scrollcontroller_helper.dart';
import '../models/audiofile_model.dart';
import '../models/block.dart';
import '../models/category_block.dart';
import '../widgets/custom_tab_button.dart';
import '../widgets/shimmerwidgets/shimmer_mp3_card_list_item_height.dart';
import '../widgets/shimmerwidgets/shimmer_mp3_card_list_item_small.dart';
import '../widgets/shimmerwidgets/shimmer_mp3_card_list_item_width.dart';
import '../widgets/tracklist_horizontal_widget.dart';

class ForMeScreen extends StatefulWidget {
  final Function panelFunction;
  final Function openExploreTab;
  final ScrollControllerHelper scrollControllerHelper;
  const ForMeScreen(this.panelFunction, this.scrollControllerHelper, this.openExploreTab,
      {super.key});
  @override
  State<ForMeScreen> createState() => _ForMeState();
}

class _ForMeState extends State<ForMeScreen> {
  bool isLoading = true;
  bool categoryBlocksIsLoading = true;
  List<AudioTrack> recentlyPlayed = [];
  List<Block> blockList = [];
  final Map<String, List<AudioTrack>> _blockTracks = {};
  List<CategoryBlock> categoryBlocks = [];
  final now = DateTime.now();

  String nickName = "";
  @override
  void initState() {
    super.initState();
    // Simulate data loading delay
    setFirstName();
    getPageBlocks();
    //getFirtList();
    fetchRecentlyPlayedTracks();
    fetchCategoryBlocks();
    //fetchRecommendedTracks();
    //getRecommendedCollectionList();
    //fetchSleepStoriesTracks(categroiesArray[0].id);
    //fetchMeditatiosTracks(categroiesArray[1].id);
    //fetchMusicTracks(categroiesArray[2].id);
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting(now.hour);
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
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
        controller: widget.scrollControllerHelper.scrollController,
        child: Column(
          children: [
            // Gif at the top with text overlay
            SizedBox(
              height: 300,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Gif image
                  Image.asset(
                    'images/background_image.png', // Replace with your image asset path
                    fit: BoxFit.fill, // Adjust the fit as needed
                  ),

                  // Text overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    top: 100,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: ValueListenableBuilder<String>(
                        valueListenable: valueNotifierName,
                        builder: (BuildContext context, String value, Widget? child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("$greeting,",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  )),
                              Text("${getNick(value)}!",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ))
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 10,
            ),

            Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Divider(
                  height: 1,
                  color: dividerColor,
                )),
            // Heading and horizontal list view of cards
            if (categoryBlocks.isNotEmpty) ...[
              SizedBox(
                height: 40,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryBlocks.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.all(5),
                      child: CustomTabButton(
                        title: categoryBlocks[index].name,
                        onPress: () {
                          widget.openExploreTab();
                          indexNotifier.value = index;
                          indexNotifier.notifyListeners();
                        },
                        color: tabUnselectedColor,
                        textColor: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ] else if (categoryBlocksIsLoading) ...[
              _buildShimmerListButton()
            ],

            Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Divider(
                  height: 1,
                  color: dividerColor,
                )),

            // Heading and horizontal list view of cards
            if (isLoading || recentlyPlayed.isNotEmpty) ...[
              Padding(
                  padding: EdgeInsets.fromLTRB(14, 4, 14, 14),
                  child: Row(
                    children: [
                      Text(
                        "Recently played",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
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
                            style: TextStyle(color: seeAllColor, fontSize: 16),
                          ))
                    ],
                  )),
              recentlyPlayed.isEmpty
                  ? _buildShimmerListViewWidth()
                  : SizedBox(
                      height: 231,
                      child: WidthTrackListHorizontal(
                        tap: () {},
                        audiList: recentlyPlayed,
                        musicList: false,
                        panelFunction: widget.panelFunction,
                      ),
                    ),
            ],

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
                                                  panelFunction: widget.panelFunction,
                                                  block: block,
                                                ));
                                          } else {
                                            pushName(
                                                context,
                                                TrackListScreen(
                                                  heading: block.title,
                                                  list: tracks,
                                                  panelFunction: widget.panelFunction,
                                                ));
                                          }
                                        },
                                        child: Text(
                                          "See all",
                                          style:
                                              TextStyle(color: seeAllColor, fontSize: 16),
                                        ))
                                ],
                              ),
                            ),
                            tracks.isEmpty
                                ? _buildShimmerListViewHeight()
                                : SizedBox(
                                    height: 231,
                                    child: TrackListHorizontal(
                                      tap: () {},
                                      audiList: tracks,
                                      musicList:
                                          block.blockType == "series" ? true : false,
                                      panelFunction: widget.panelFunction,
                                    )),
                          ],
                        );
                      }
                    },
                  ),

            // blockList.isEmpty
            //     ? _buildShimmerListViewHeightWithTitle()
            // :ListView.builder(
            //   itemCount: blockList.length,
            //   physics: NeverScrollableScrollPhysics(),
            //   shrinkWrap: true,
            //   itemBuilder: (context, index) {
            //     final block = blockList[index];
            //     return FutureBuilder<List<AudioTrack>>(
            //       future: fetchTracksForBlock(block.id),
            //       builder: (context, snapshot) {
            //         if (snapshot.connectionState == ConnectionState.waiting) {
            //           return Column(
            //             children: [
            //               Padding(
            //                 padding: EdgeInsets.fromLTRB(14, 14,14,14),
            //                 child:
            //                 Row(
            //                 children:[
            //                   Text(
            //                     block.title,
            //                     style: TextStyle(
            //                       fontSize: 22,
            //                       fontWeight: FontWeight.bold,
            //                     ),
            //                   ),
            //                 ]
            //                 )
            //               ),
            //               _buildShimmerListViewHeight()
            //             ],
            //           );
            //         } else if (snapshot.hasError) {
            //           return Text('Error: ${snapshot.error}');
            //         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //           return Column(
            //             children: [
            //               Padding(
            //                 padding: EdgeInsets.fromLTRB(14, 14,14,14),
            //                 child: Row(
            //                   children: [
            //                     Text(
            //                       block.title,
            //                       style: TextStyle(
            //                         fontSize: 22,
            //                         fontWeight: FontWeight.bold,
            //                       ),
            //                     ),],
            //
            //                 ),),
            //
            //               Text("No tracks available")
            //
            //             ],
            //           );
            //         } else {
            //           final tracks = snapshot.data!;
            //           return Column(
            //             children: [
            //               Padding(
            //                 padding: EdgeInsets.fromLTRB(14, 14,14,14),
            //                 child: Row(
            //                   children: [
            //                     Text(
            //                       block.title,
            //                       style: TextStyle(
            //                         fontSize: 22,
            //                         fontWeight: FontWeight.bold,
            //                       ),
            //                     ),
            //
            //                     Spacer(),
            //                     if(tracks.isNotEmpty)
            //                       TextButton(onPressed: (){
            //                         pushName(context, TrackListScreen(heading:block.title,list: tracks,panelFunction: widget.panelFunction,));
            //
            //                       }, child:Text("See all",style: TextStyle(color: blueAccentColor,fontSize: 16),))
            //                   ],
            //
            //                 ),),
            //
            //         tracks.isEmpty
            //         ? _buildShimmerListViewHeight()
            //             : SizedBox(
            //         height: 231,
            //         child: TrackListHorizontal(tap: (){
            //
            //         },audiList: tracks,musicList: false,panelFunction: widget.panelFunction,)
            //         ),
            //
            //             ],
            //           );
            //
            //
            //         }
            //       },
            //     );
            //   },
            // ),

            //    // Horizontal list view of cards
            //    audioList1.isEmpty
            //        ? _buildShimmerListViewWidth()
            //        : SizedBox(
            //      height: 231,
            //      child:WidthTrackListHorizontal(audiList: audioList1, tap: (){
            //
            //      }, musicList: false,panelFunction: widget.panelFunction,)
            //    ),
            //
            //    // Four buttons in two rows
            //    Row(
            //      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //      children: [
            //
            //         Expanded(child:
            //             Padding(
            //        padding: EdgeInsets.fromLTRB(16,16,7,8),
            //         child:   CustomButton(title:categroiesArray[0].categoryName,onPress: (){
            //           pushName(context, TrackListSearchScreen(category: categroiesArray[0],panelFunction: widget.panelFunction,));
            //
            //         },color: lightBlueColor,textColor: Colors.white,)
            //               ,
            //
            //         )
            //            ),
            //
            //
            //
            //        Expanded(child:
            //        Padding(
            //          padding: EdgeInsets.fromLTRB(7,16,16,8),
            //          child:   CustomButton(title:categroiesArray[1].categoryName,onPress: (){
            //            pushName(context, TrackListSearchScreen(category: categroiesArray[1],panelFunction: widget.panelFunction,));
            //          },color: lightBlueColor,textColor: Colors.white,)
            //          ,
            //
            //        )
            //        ),
            //      ],
            //    ),
            //    Row(
            //      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //      children: [
            //
            //        Expanded(child:
            //        Padding(
            //          padding: EdgeInsets.fromLTRB(16,8,7,0),
            //          child:   CustomButton(title:categroiesArray[2].categoryName,onPress: (){
            //            pushName(context, TrackListSearchScreen(category: categroiesArray[2],panelFunction: widget.panelFunction,));
            //          },color: lightBlueColor,textColor: Colors.white,)
            //          ,)
            //        ),
            //
            //
            //
            //        Expanded(child:
            //        Padding(
            //        padding: EdgeInsets.fromLTRB(7,8,16,0),
            //          child:   CustomButton(title:categroiesArray[3].categoryName,onPress: (){
            //            pushName(context, TrackListSearchScreen(category: categroiesArray[4],panelFunction: widget.panelFunction,));
            //          },color: lightBlueColor,textColor: Colors.white,)
            //          ,
            //
            //        )
            //        ),
            //      ],
            //    ),
            //

            //
            //
            //    if(recommenedTrackIsLoading || recommendedTrackList.isNotEmpty)...[
            //      // Heading and horizontal list view of cards
            //      Padding(
            //          padding: EdgeInsets.fromLTRB(16, 32,16,16),
            //          child: Row(
            //            children: [
            //              Text(
            //                "Recommended for you",
            //                style: TextStyle(
            //                  fontSize: 22,
            //                  fontWeight: FontWeight.bold,
            //                ),
            //              ),
            //
            //              Spacer(),
            //              if(recommendedTrackList.isNotEmpty)
            //                TextButton(onPressed: (){
            //                  pushName(context, TrackListScreen(heading: "Recommended for you",list: recommendedTrackList,panelFunction: widget.panelFunction,));
            //
            //                }, child:Text("See all",style: TextStyle(color: blueAccentColor,fontSize: 16),))
            //            ],
            //
            //          )
            //      ),
            //      recommendedTrackList.isEmpty
            //          ? _buildShimmerListViewHeight()
            //          : SizedBox(
            //          height: 231,
            //          child: TrackListHorizontal(tap: (){
            //
            //          },audiList: recommendedTrackList,musicList: false,panelFunction: widget.panelFunction,)
            //      ),
            //
            //
            //
            //    ],
            //
            //
            //
            //      if(collectionsIsLoading || recommendedCollectionList.isNotEmpty)...[
            //    Padding(
            //        padding: EdgeInsets.fromLTRB(16, 32,16,16),
            //        child: Row(
            //          children: [
            //            Text(
            //              "Recommended Collections",
            //              style: TextStyle(
            //                fontSize: 22,
            //                fontWeight: FontWeight.bold,
            //              ),
            //            ),
            //
            //            Spacer(),
            //            if(recommendedCollectionList.isNotEmpty)
            //            TextButton(onPressed: (){
            //              pushName(context, CollectionListScreen(heading: "Recommended Collections",list:recommendedCollectionList,panelFunction: widget.panelFunction,));
            //            }, child:Text("See all",style: TextStyle(color: lightBlueColor,fontSize: 16),))
            //          ],
            //
            //        )
            //    ),
            //    recommendedCollectionList.isEmpty
            //        ? _buildShimmerListViewSmall()
            //        : SizedBox(
            //      height: 136,
            //      child: ListView.separated(
            //        padding: EdgeInsets.only(left:16),
            //        scrollDirection: Axis.horizontal,
            //        itemCount: recommendedCollectionList.length,
            //        separatorBuilder: (BuildContext context, int index) {
            //          return SizedBox(width: 16);
            //        },
            //        itemBuilder: (BuildContext context, int index) {
            //          return Mp3ItemSmall(
            //            imageUrl: recommendedCollectionList[index].collectionThumbnail,
            //            mp3Name: recommendedCollectionList[index].collectionTitle,
            //            mp3Category: recommendedCollectionList[index].collectionCategory[0].categoryName,
            //            tap: (){
            //              pushName(context, TrackListScreen(heading: recommendedCollectionList[index].collectionTitle, list: recommendedCollectionList[index].collectionTracks,panelFunction: widget.panelFunction,));
            //            },
            //          );
            //        },
            //      ),
            //    ),
            // ],
            //
            //
            //    if(sleepStoriesIsLoading || sleepStoriesList.isNotEmpty)...[
            //      // Heading and horizontal list view of cards
            //      Padding(
            //          padding: EdgeInsets.fromLTRB(16, 32,16,16),
            //          child: Row(
            //            children: [
            //              Text(
            //                categroiesArray[0].categoryName,
            //                style: TextStyle(
            //                  fontSize: 22,
            //                  fontWeight: FontWeight.bold,
            //                ),
            //              ),
            //
            //              Spacer(),
            //              if(sleepStoriesList.isNotEmpty)
            //                TextButton(onPressed: (){
            //                  pushName(context, TrackListScreen(heading:categroiesArray[0].categoryName,list: sleepStoriesList,panelFunction: widget.panelFunction,));
            //
            //                }, child:Text("See all",style: TextStyle(color: blueAccentColor,fontSize: 16),))
            //            ],
            //
            //          )
            //      ),
            //      sleepStoriesList.isEmpty
            //          ? _buildShimmerListViewHeight()
            //          : SizedBox(
            //          height: 231,
            //          child: TrackListHorizontal(tap: (){
            //
            //          },audiList: sleepStoriesList,musicList: false,panelFunction: widget.panelFunction,)
            //      ),
            //
            //
            //
            //    ],
            //
            //
            //    if(meditationsIsLoading || meditationsList.isNotEmpty)...[
            //      // Heading and horizontal list view of cards
            //      Padding(
            //          padding: EdgeInsets.fromLTRB(16, 32,16,16),
            //          child: Row(
            //            children: [
            //              Text(
            //                categroiesArray[1].categoryName,
            //                style: TextStyle(
            //                  fontSize: 22,
            //                  fontWeight: FontWeight.bold,
            //                ),
            //              ),
            //
            //              Spacer(),
            //              if(meditationsList.isNotEmpty)
            //                TextButton(onPressed: (){
            //                  pushName(context, TrackListScreen(heading:categroiesArray[1].categoryName,list: meditationsList,panelFunction: widget.panelFunction,));
            //
            //                }, child:Text("See all",style: TextStyle(color: blueAccentColor,fontSize: 16),))
            //            ],
            //
            //          )
            //      ),
            //      meditationsList.isEmpty
            //          ? _buildShimmerListViewHeight()
            //          : SizedBox(
            //          height: 231,
            //          child: WidthTrackListHorizontalNew(tap: (){
            //
            //          },audiList: meditationsList,musicList: false,panelFunction: widget.panelFunction,)
            //      ),
            //
            //
            //
            //    ],
            //
            //    if(musicIsLoading || musicList.isNotEmpty)...[
            //      // Heading and horizontal list view of cards
            //      Padding(
            //          padding: EdgeInsets.fromLTRB(16, 32,16,16),
            //          child: Row(
            //            children: [
            //              Text(
            //                categroiesArray[2].categoryName,
            //                style: TextStyle(
            //                  fontSize: 22,
            //                  fontWeight: FontWeight.bold,
            //                ),
            //              ),
            //
            //              Spacer(),
            //              if(musicList.isNotEmpty)
            //                TextButton(onPressed: (){
            //                  pushName(context, TrackListScreen(heading:categroiesArray[2].categoryName,list: musicList,panelFunction: widget.panelFunction,));
            //
            //                }, child:Text("See all",style: TextStyle(color: blueAccentColor,fontSize: 16),))
            //            ],
            //
            //          )
            //      ),
            //      musicList.isEmpty
            //          ? _buildShimmerListViewHeight()
            //          : SizedBox(
            //          height: 231,
            //          child: TrackListHorizontal(tap: (){
            //
            //          },audiList: musicList,musicList: true,panelFunction: widget.panelFunction,)
            //      ),
            //
            //
            //
            //    ],

            SizedBox(
              height: 165,
            ),
          ],
        ),
      ),
    ));
  }

  Future<void> getPageBlocks() async {
    blockList = await getHomePageBlocks();
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

  // Future<void> getRecommendedCollectionList() async {
  //   recommendedCollectionList = await getCollections();
  //   collectionsIsLoading = false;
  //   setState(() {
  //
  //   });
  // }
  //
  // void fetchSleepStoriesTracks(String cat) async {
  //   sleepStoriesList = await getPopularTracksByCategory(cat);
  //   sleepStoriesIsLoading = false;
  //   setState(() {
  //   });
  // }
  // void fetchMeditatiosTracks(String cat) async {
  //   meditationsList = await getPopularTracksByCategory(cat);
  //   meditationsIsLoading = false;
  //   setState(() {
  //   });
  // }
  // void fetchMusicTracks(String cat) async {
  //   musicList = await getPopularTracksByCategory(cat);
  //   musicIsLoading = false;
  //   setState(() {
  //   });
  // }
  //
  // void fetchRecommendedTracks() async {
  //   recommendedTrackList = await getRecommendedTracks();
  //   recommenedTrackIsLoading = false;
  //   setState(() {
  //   });
  // }

  // Future<void> getFirtList() async {
  //
  //   QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Tracks').orderBy("updated_on", descending: true).limit(10).get();
  //
  //   for (var document in snapshot.docs) {
  //     AudioTrack track = AudioTrack.fromFirestore(document);
  //     setState(() {
  //       audioList1.add(track);
  //     });
  //
  //   }
  //
  //
  // }

  Widget _buildShimmerListButton() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(padding: EdgeInsets.all(5), child: ShimmerCustomTabButton());
        },
      ),
    );
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

  Widget _buildShimmerListViewTab() {
    return SizedBox(
      height: 40,
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

  String _getGreeting(int hour) {
    if (hour >= 5 && hour < 12) {
      return translation(context).goodMorning;
    } else if (hour >= 12 && hour < 17) {
      return translation(context).goodAfternoon;
    } else if (hour >= 17 && hour < 21) {
      return translation(context).goodEvening;
    } else {
      return translation(context).goodNight;
    }
  }

  void setFirstName() async {
    UserModel user = await getUser();
    String? fullName = user.name;
    valueNotifierName.value = fullName!;
    List<String> words = fullName.split(' ');
    setState(() {
      nickName = words.first;
    });
  }

  String getNick(String? name) {
    List<String> words = name!.split(' ');

    return words.first;
  }

  void fetchRecentlyPlayedTracks() async {
    recentlyPlayed = await getRecentlyPlayedTracks();
    isLoading = false;
    setState(() {});
  }

  void fetchCategoryBlocks() async {
    categoryBlocks = await getCategoryBlocks();
    categoryBlocksIsLoading = false;
    setState(() {});
  }
}
