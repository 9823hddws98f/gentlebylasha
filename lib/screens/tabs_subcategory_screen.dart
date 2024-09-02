import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sleeptales/models/sub_categories.dart';
import 'package:sleeptales/models/user_model.dart';
import 'package:sleeptales/screens/playlist_screen.dart';
import 'package:sleeptales/screens/subcategories_tab.dart';
import 'package:sleeptales/screens/track_list.dart';
import 'package:sleeptales/utils/colors.dart';
import 'package:sleeptales/utils/firestore_helper.dart';
import 'package:sleeptales/utils/global_functions.dart';
import 'package:sleeptales/widgets/custom_tab_button.dart';
import '../models/audiofile_model.dart';
import '../models/block.dart';
import '../models/category_block.dart';
import '../models/collection_model.dart';
import '../widgets/shimmerwidgets/shimmer_mp3_card_list_item_height.dart';
import '../widgets/shimmerwidgets/shimmer_mp3_card_list_item_small.dart';
import '../widgets/shimmerwidgets/shimmer_mp3_card_list_item_width.dart';
import '../widgets/tracklist_horizontal_widget.dart';


class TabsSubCategoryScreen extends StatefulWidget {
  final CategoryBlock category;
  final Function panelFunction;
  const TabsSubCategoryScreen(this.category,this.panelFunction, {super.key});
  @override
  _TabsSubCategoryScreen createState() => _TabsSubCategoryScreen();
}

class _TabsSubCategoryScreen extends State<TabsSubCategoryScreen> with TickerProviderStateMixin,AutomaticKeepAliveClientMixin{
  bool recentIsLoading = true;
  bool popularIsLoading = true;
  bool collectionsIsLoading = true;
  bool subCategoriesIsLoading = true;
  List<AudioTrack> audioList1 = [];
  List<AudioTrack> recentlyPlayed = [];
  List<AudioTrack> popularCat = [];
  List<Collection> topCollection = [];
  List<SubCategory> subCategories = [];
  String nickName = "";
  late TabController _tabControllerNew;
  List<Block> blockList = [];
  Map<String, List<AudioTrack>> _blockTracks = {};



  @override
  void initState() {
    super.initState();
    _tabControllerNew = TabController(length: 0, vsync: this);

    getPageBlocks();
    getSubCategories(widget.category.id);

  }
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
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
          child:NestedScrollView(
            headerSliverBuilder: (context, value) {
              return [
                SliverToBoxAdapter(
                  child:Column(
                       children: [

                         blockList.isEmpty
                             ? _buildShimmerListViewHeightWithTitle()
                             : ListView.builder(
                           physics: NeverScrollableScrollPhysics(),
                           shrinkWrap: true,
                           padding: EdgeInsets.only(top: 0.h),
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
                                       padding: EdgeInsets.fromLTRB(14.w, 14.h,14.w,14.h),
                                       child:
                                       Row(
                                           children:[
                                             Text(
                                               block.title,
                                               style: TextStyle(
                                                 fontSize: 22.sp,
                                                 fontWeight: FontWeight.bold,
                                               ),
                                             ),
                                           ]
                                       )
                                   ),
                                   _buildShimmerListViewHeight()
                                 ],
                               );// or a loading indicator
                             } else if (tracks.isEmpty) {
                               // Handle the case when there are no tracks
                               return Column(
                                 children: [
                                   Padding(
                                     padding: EdgeInsets.fromLTRB(14.w, 14.h,14.w,14.h),
                                     child: Row(
                                       children: [
                                         Text(
                                           block.title,
                                           style: TextStyle(
                                             fontSize: 22.sp,
                                             fontWeight: FontWeight.bold,
                                           ),
                                         ),],

                                     ),),

                                   Text("No tracks available")

                                 ],
                               );
                             } else {
                               // Display the list of tracks for this block
                               return Column(
                                 children: [
                                   Padding(
                                     padding: EdgeInsets.fromLTRB(14.w, 14.h,14.w,14.h),
                                     child: Row(
                                       children: [
                                         Text(
                                           block.title,
                                           style: TextStyle(
                                             fontSize: 22.sp,
                                             fontWeight: FontWeight.bold,
                                           ),
                                         ),

                                         Spacer(),
                                         if(tracks.isNotEmpty)
                                           TextButton(onPressed: (){
                                             if(block.blockType == "series"){
                                               pushName(context, PlayListScreen(list: tracks,panelFunction: widget.panelFunction,block: block,));
                                             }else{
                                               pushName(context, TrackListScreen(heading:block.title,list: tracks,panelFunction: widget.panelFunction,));
                                             }
                                             //pushName(context, TrackListScreen(heading:block.title,list: tracks,panelFunction: widget.panelFunction,));

                                           }, child:Text("See all",style: TextStyle(color: seeAllColor,fontSize: 16.sp),))
                                       ],

                                     ),),

                                   tracks.isEmpty
                                       ? _buildShimmerListViewHeight()
                                       : SizedBox(
                                       height: 231.h,
                                       child: TrackListHorizontal(tap: (){

                                       },audiList: tracks,musicList: block.blockType == "series"?true:false,panelFunction: widget.panelFunction,)
                                   ),

                                   Padding(padding: EdgeInsets.all(16.w),
                                     child: Divider(height: 1,color: dividerColor,),
                                   )
                                 ],
                               );
                             }
                           },
                         ),




              //            Padding(
              //                padding: EdgeInsets.fromLTRB(16.w, 15.h,16.w,16.h),
              //                child: Row(
              //                  children: [
              //                    Text(
              //                      "Featured",
              //                      style: TextStyle(
              //                        fontSize: 22.sp,
              //                        fontWeight: FontWeight.bold,
              //                      ),
              //                    ),
              //
              //                    Spacer(),
              //                    if(audioList1.isNotEmpty)
              //                      TextButton(onPressed: (){
              //                        pushName(context, TrackListScreen(heading: "Featured",list: audioList1,panelFunction: widget.panelFunction,));
              //
              //                      }, child:Text("See all",style: TextStyle(color: blueAccentColor,fontSize: 16.sp),))
              //                  ],
              //
              //                )
              //            ),
              //            audioList1.isEmpty
              //                ? _buildShimmerListViewWidth()
              //                : SizedBox(
              //                height: 231.h,
              //                child: WidthTrackListHorizontal(audiList: audioList1, tap: (){
              //
              //                }, musicList: widget.category.name == "Music"?true:false,panelFunction: widget.panelFunction,)
              //            ),
              // if(subCategories.isNotEmpty)...[
              //            Padding(padding: EdgeInsets.only(left: 11.w),
              //              child:Container(
              //              width: MediaQuery.of(context).size.width,
              //               child: TabBar(
              //                  labelPadding: EdgeInsets.all(4.w),
              //                  controller: TabController(length: 5, vsync: Scaffold.of(context)),
              //                  isScrollable: true,
              //                  indicatorColor: Colors.transparent,
              //                  tabs: [
              //                    ...subCategories.map((category) {
              //                      int index = subCategories.indexOf(category);
              //                      return Tab(
              //                        child: CustomTabButton(
              //                          title: category.name,
              //                          onPress: () {
              //                            _tabControllerNew.animateTo(index);
              //                            setState(() {});
              //                          },
              //                          color: _tabControllerNew.index == index ? tabSelectedColor : tabUnselectedColor,
              //                          textColor: Colors.white,
              //                        ),
              //                      );
              //                    }).toList(),
              //                  ])),
              //            ),
              //  ]


              ],
              )
                ),

              ];
            },
            body: Container(
              child:  (subCategories.isNotEmpty)?
              TabBarView(
                controller: _tabControllerNew,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                 // AllSubCategoriesTab(subCategories: subCategories, category: widget.category,panelFunction: widget.panelFunction,),
                  for (SubCategory category in subCategories)
                    SubCategoriesTab(category,widget.panelFunction)
                ],
              ):SizedBox(
              )
            ),
          )

        )
    );
  }

  // Function to fetch tracks for a block and update the state
  Future<void> fetchAndSetTracks(String blockId) async {
    final tracks = await fetchTracksForBlock(blockId);
    setState(() {
      _blockTracks[blockId] = tracks;
    });
    print(tracks.length);
  }
  Future<void> getPageBlocks() async {

    blockList = await getBlockOfCategory(widget.category.id);
    setState(() {
    });

  }


  Future<void> getFeaturedList(String cat) async {

    audioList1 = await getFeaturedByCategory(cat);
    setState(() {

    });

  }


  void fetchPopularTracks(String cat) async {
    popularCat = await getPopularTracksByCategory(cat);
    popularIsLoading = false;
    setState(() {
    });
  }

  Widget _buildShimmerListViewHeightWithTitle() {
    return Column(
      children: [
        // Heading and horizontal list view of cards
        Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h,14.w,14.h),
            child: Row(
              children: [
                Text(
                  "       ",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Spacer(),
                TextButton(onPressed: (){

                }, child:Text("    ",style: TextStyle(color: blueAccentColor,fontSize: 16.sp),))
              ],

            )
        ),
        SizedBox(
          height: 231.h,
          child:ListView.separated(
            padding: EdgeInsets.only(left:16.w),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(width: 16.w);
            },
            itemBuilder: (BuildContext context, int index) {
              return Mp3ListItemShimmerHeight();
            },
          ),
        )


      ],
    );
  }
  Widget _buildShimmerListViewWidth() {
    return SizedBox(
      height: 231.h,
      child:ListView.separated(
        padding: EdgeInsets.only(left:16.w),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(width: 16.w);
        },
        itemBuilder: (BuildContext context, int index) {
          return Mp3ListItemShimmer();
        },
      ),
    );
  }


  Widget _buildShimmerListViewHeight() {
    return SizedBox(
      height: 231.h,
      child:ListView.separated(
        padding: EdgeInsets.only(left:16.w),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(width: 16.w);
        },
        itemBuilder: (BuildContext context, int index) {
          return Mp3ListItemShimmerHeight();
        },
      ),
    );
  }
  Widget _buildShimmerListViewSmall() {
    return SizedBox(
      height: 133.h,
      child:ListView.separated(
        padding: EdgeInsets.only(left:16.w),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(width: 16.w);
        },
        itemBuilder: (BuildContext context, int index) {
          return Mp3ListItemShimmerSmall();
        },
      ),
    );
  }


  void setFirstName() async{
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
    setState(() {
    });
  }

  void fetchTopCollections(String cat) async {
    topCollection = await getTopCollections(cat);
    collectionsIsLoading = false;
    setState(() {
    });
  }

  void getSubCategories(String cat) async {
    subCategories = await fetchSubcategoriesBlocks(cat);
    subCategoriesIsLoading = false;
    if(subCategories.isNotEmpty){
      print("subcat ${subCategories.length}");
      _updateTabControllerLength(subCategories.length);
    }
    setState(() {
    });
  }

  @override
  void dispose() {
    _tabControllerNew.dispose();
    super.dispose();
  }


  void _updateTabControllerLength(int newLength) {
    setState(() {
      _tabControllerNew = TabController(length: (newLength+1), vsync: this);
    });
  }
}