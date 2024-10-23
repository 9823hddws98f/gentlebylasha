import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '/models/sub_categories.dart';
import '/screens/track_list.dart';
import '/utils/colors.dart';
import '/utils/firestore_helper.dart';
import '/utils/global_functions.dart';
import '/widgets/tracklist_horizontal_widget.dart';
import '../models/audiofile_model.dart';
import '../models/category_block.dart';
import '../models/collection_model.dart';
import '../widgets/shimmerwidgets/shimmer_mp3_card_list_item_height.dart';

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
                      padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 16.h),
                      child: Row(
                        children: [
                          Text(
                            "Recently played",
                            style: TextStyle(
                              fontSize: 22.sp,
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
                                  style:
                                      TextStyle(color: blueAccentColor, fontSize: 16.sp),
                                ))
                        ],
                      )),
                  recentlyPlayed.isEmpty
                      ? _buildShimmerListViewHeight()
                      : SizedBox(
                          height: 231.h,
                          child: TrackListHorizontal(
                            tap: () {},
                            audiList: recentlyPlayed,
                            musicList: widget.category.name == "Music" ? true : false,
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
                        return SizedBox(width: 0.w);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                                padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 16.h),
                                child: Row(
                                  children: [
                                    Text(
                                      topCollection[index].collectionTitle,
                                      style: TextStyle(
                                        fontSize: 22.sp,
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
                                                panelFunction: widget.panelFunction,
                                              ));
                                        },
                                        child: Text(
                                          "See all",
                                          style: TextStyle(
                                              color: blueAccentColor, fontSize: 16.sp),
                                        ))
                                  ],
                                )),
                            topCollection[index].collectionTracks.isEmpty
                                ? _buildShimmerListViewHeight()
                                : SizedBox(
                                    height: 231.h,
                                    child: TrackListHorizontal(
                                      tap: () {},
                                      audiList: topCollection[index].collectionTracks,
                                      musicList:
                                          widget.category.name == "Music" ? true : false,
                                      panelFunction: widget.panelFunction,
                                    )),
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
                  height: 165.h,
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
            padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 16.h),
            child: Row(
              children: [
                Container(
                    width: 120.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: shimmerBaseColor,
                      borderRadius: BorderRadius.circular(20),
                    )),
                Spacer(),
                Container(
                    width: 80.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: shimmerBaseColor,
                      borderRadius: BorderRadius.circular(20),
                    ))
              ],
            )),
        SizedBox(
          height: 231.h,
          child: ListView.separated(
            padding: EdgeInsets.only(left: 16.w),
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

  Widget _buildShimmerListViewHeight() {
    return SizedBox(
      height: 231.h,
      child: ListView.separated(
        padding: EdgeInsets.only(left: 16.w),
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
