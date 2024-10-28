import 'package:flutter/material.dart';
import 'package:sleeptales/screens/home/track_bloc_loader.dart';

import '/domain/blocs/user/app_user.dart';
import '/domain/models/audiofile_model.dart';
import '/domain/models/block.dart';
import '/domain/models/category_block.dart';
import '/domain/models/collection_model.dart';
import '/domain/models/sub_categories.dart';
import '/utils/firestore_helper.dart';
import '/utils/global_functions.dart';

class TabsSubCategoryScreen extends StatefulWidget {
  final CategoryBlock category;
  const TabsSubCategoryScreen(this.category, {super.key});
  @override
  State<TabsSubCategoryScreen> createState() => _TabsSubCategoryScreen();
}

class _TabsSubCategoryScreen extends State<TabsSubCategoryScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
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
  final Map<String, List<AudioTrack>> _blockTracks = {};

  @override
  void initState() {
    super.initState();
    _tabControllerNew = TabController(length: 0, vsync: this);

    getPageBlocks();
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return blockList.isEmpty
        ? ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) => TrackBlockLoader.shimmer(),
          )
        : ListView.builder(
            itemCount: blockList.length,
            itemBuilder: (context, index) => TrackBlockLoader(blockList[index]),
          );
  }

  // Function to fetch tracks for a block and update the state
  Future<void> fetchAndSetTracks(String blockId) async {
    final tracks = await fetchTracksForBlock(blockId);
    setState(() {
      _blockTracks[blockId] = tracks;
    });
    debugPrint(tracks.length.toString());
  }

  Future<void> getPageBlocks() async {
    blockList = await getBlockOfCategory(widget.category.id);
    setState(() {});
  }

  Future<void> getFeaturedList(String cat) async {
    audioList1 = await getFeaturedByCategory(cat);
    setState(() {});
  }

  void fetchPopularTracks(String cat) async {
    popularCat = await getPopularTracksByCategory(cat);
    popularIsLoading = false;
    setState(() {});
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

  void fetchTopCollections(String cat) async {
    topCollection = await getTopCollections(cat);
    collectionsIsLoading = false;
    setState(() {});
  }

  @override
  void dispose() {
    _tabControllerNew.dispose();
    super.dispose();
  }
}
