import 'package:flutter/material.dart';

import '/domain/models/audiofile_model.dart';
import '/domain/models/block.dart';
import '/domain/services/language_constants.dart';
import '/screens/home/block_header.dart';
import '/screens/track_list.dart';
import '/utils/app_theme.dart';
import '/utils/firestore_helper.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/mp3_list_item.dart';
import '/widgets/tracklist_horizontal_widget.dart';
import 'category_list.dart';
import 'track_bloc_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with Translation {
  List<AudioTrack> _recentlyPlayed = [];
  List<Block> _blockList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getPageBlocks();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isMobile) => AdaptiveAppBar(
          title: tr.home,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(68),
            child: Column(
              children: [
                CategoryList(
                  onTap: (categoryBlock) {
                    // TODO: open explore tab
                    // indexNotifier.value = index;
                    // indexNotifier.notifyListeners();
                  },
                ),
                SizedBox(height: 16),
                Divider(height: 1),
              ],
            ),
          ),
        ),
        bodyPadding: EdgeInsets.zero,
        body: (context, isMobile) => CustomScrollView(
          cacheExtent: 600,
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: _buildRecentlyPlayed(Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SliverToBoxAdapter(child: Divider()),
            _blockList.isEmpty
                ? SliverList.separated(
                    separatorBuilder: (_, __) => Divider(),
                    itemBuilder: (_, __) => TrackBlockLoader.shimmer(),
                  )
                : SliverList.separated(
                    separatorBuilder: (_, __) => Divider(),
                    itemCount: _blockList.length,
                    itemBuilder: (_, index) => TrackBlockLoader(_blockList[index]),
                  ),
            SliverToBoxAdapter(child: SizedBox(height: 150)),
          ],
        ),
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
              : TrackListHorizontal(
                  trackList: _recentlyPlayed,
                  isWide: true,
                ),
        ],
      );

  Widget _buildShimmerListViewWidth() => SizedBox(
        height: TrackListHorizontal.height,
        child: ListView.separated(
          padding: EdgeInsets.only(left: AppTheme.sidePadding),
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (context, index) => SizedBox(width: 16),
          itemBuilder: (context, index) => Mp3ListItem.shimmer(true),
        ),
      );

  void getPageBlocks() async {
    final blocks = await getHomePageBlocks();
    final recentlyPlayed = await getRecentlyPlayedTracks();
    if (mounted) {
      setState(() {
        _blockList = blocks;
        _recentlyPlayed = recentlyPlayed;
      });
    }
  }
}
