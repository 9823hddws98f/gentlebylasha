import 'package:flutter/material.dart';
import 'package:sleeptales/utils/app_theme.dart';

import '/domain/models/audiofile_model.dart';
import '/domain/models/block.dart';
import '/domain/services/language_constants.dart';
import '/screens/home/block_header.dart';
import '/screens/track_list.dart';
import '/utils/firestore_helper.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/shimmerwidgets/shimmer_mp3_card_list_item_height.dart';
import '/widgets/shimmerwidgets/shimmer_mp3_card_list_item_width.dart';
import '/widgets/width_tracklist_horizontal_widget.dart';
import 'category_list.dart';
import 'track_list_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _ForMeState();
}

class _ForMeState extends State<HomeScreen> with Translation {
  List<AudioTrack> _recentlyPlayed = [];
  List<Block> _blockList = [];

  @override
  void initState() {
    super.initState();
    getPageBlocks();
    fetchRecentlyPlayedTracks();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isMobile) => AppBar(
          title: Text(tr.home),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(68),
            child: Column(
              children: [
                CategoryList(),
                Divider(height: 1),
              ],
            ),
          ),
        ),
        bodyPadding: EdgeInsets.zero,
        body: (context, isMobile) {
          final colors = Theme.of(context).colorScheme;
          final seeAllColor = colors.onSurfaceVariant;
          return CustomScrollView(
            cacheExtent: 600,
            slivers: [
              SliverToBoxAdapter(child: _buildRecentlyPlayed(seeAllColor)),
              _blockList.isEmpty
                  ? SliverList.builder(
                      itemBuilder: (_, index) => _buildShimmerListViewHeightWithTitle())
                  : SliverList.builder(
                      itemCount: _blockList.length,
                      itemBuilder: (context, index) => TrackListLoader(_blockList[index]),
                    ),
              SliverToBoxAdapter(child: SizedBox(height: 150)),
            ],
          );
        },
      );

  Widget _buildRecentlyPlayed(Color seeAllColor) => Column(
        children: [
          BlockHeader(
            title: 'Recently played',
            seeAll: _recentlyPlayed.isNotEmpty
                ? TrackListScreen(
                    heading: 'Recently Played',
                    list: _recentlyPlayed,
                  )
                : null,
          ),
          _recentlyPlayed.isEmpty
              ? _buildShimmerListViewWidth()
              : SizedBox(
                  height: 231,
                  child: WidthTrackListHorizontal(
                    onTap: () {},
                    trackList: _recentlyPlayed,
                    musicList: false,
                  ),
                ),
        ],
      );

  Widget _buildShimmerListViewWidth() => SizedBox(
        height: 231,
        child: ListView.separated(
          padding: EdgeInsets.only(left: AppTheme.sidePadding),
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (context, index) => SizedBox(width: 16),
          itemBuilder: (context, index) => Mp3ListItemShimmer(),
        ),
      );

  Widget _buildShimmerListViewHeightWithTitle() => Column(
        children: [
          BlockHeader.shimmer(),
          SizedBox(
            height: 231,
            child: ListView.separated(
              padding: EdgeInsets.only(left: AppTheme.sidePadding),
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (context, index) => SizedBox(width: 16),
              itemBuilder: (context, index) => Mp3ListItemShimmerHeight(),
            ),
          )
        ],
      );

  Future<void> getPageBlocks() async {
    _blockList = await getHomePageBlocks();
    setState(() {});
  }

  void fetchRecentlyPlayedTracks() async {
    _recentlyPlayed = await getRecentlyPlayedTracks();
    setState(() {});
  }
}
