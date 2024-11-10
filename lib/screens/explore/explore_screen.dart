import 'package:animations/animations.dart';
import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleeptales/widgets/app_scaffold/bottom_panel_spacer.dart';

import '/domain/cubits/pages/pages_cubit.dart';
import '/domain/models/block_item/audio_track.dart';
import '/domain/services/tracks_service.dart';
import '/screens/home/category_list.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/utils/tx_loader.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/blocks/page_block_builder.dart';
import '/widgets/input/tx_search_bar.dart';
import '/widgets/shared_axis_switcher.dart';
import 'widgets/search_list_item.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  final _trackService = Get.the<TracksService>();
  final _pagesCubit = Get.the<PagesCubit>();

  late final TabController _tabController;
  final _scrollController = ScrollController();

  /// Search
  final _txLoader = TxLoader();
  String _query = '';
  List<AudioTrack> _tracks = [];
  String? _error;
  bool get _isSearching => _query.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _pagesCubit.state.explorePages.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        resizeToAvoidBottomInset: false,
        bodyPadding: EdgeInsets.zero,
        appBar: (context, isMobile) => AdaptiveAppBar(
          title: 'Explore',
          hasBottomLine: false,
        ),
        body: (context, isMobile) {
          final colors = Theme.of(context).colorScheme;
          return NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, value) => [
              _buildSearchbar(isMobile, colors.outline),
              SliverToBoxAdapter(child: SizedBox(height: 12)),
              _buildCategoriesList(),
              /* Rigorously eyeballed padding values */
              SliverToBoxAdapter(child: SizedBox(height: 8)),
            ],
            body: SharedAxisSwitcher(
              disableFillColor: true,
              transitionType: SharedAxisTransitionType.scaled,
              child: _isSearching
                  ? _buildSearchView(colors.onSurfaceVariant)
                  : BlocBuilder<PagesCubit, PagesState>(
                      bloc: _pagesCubit,
                      builder: (context, state) => state.explorePages.isEmpty
                          ? Center(child: Text('No categories found'))
                          : TabBarView(
                              physics: NeverScrollableScrollPhysics(),
                              controller: _tabController,
                              children: state.explorePages.keys
                                  .map(
                                    (page) => PageBlockBuilder(
                                      key: ValueKey(page.id),
                                      page: page,
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
            ),
          );
        },
      );

  Widget _buildSearchView(Color color) {
    if (_error != null) return Text('Error: $_error');
    if (_txLoader.loading) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      );
    } else if (_tracks.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CarbonIcons.search, size: 62, color: color),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: TextStyle(color: color),
              children: [
                TextSpan(text: 'Couldn\'t find "'),
                TextSpan(
                  text: _query,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: '"'),
              ],
            ),
          ),
        ],
      );
    }
    return BottomPanelSpacer.padding(
      child: ListView.separated(
        itemCount: _tracks.length,
        cacheExtent: 1000,
        separatorBuilder: (context, index) => const SizedBox(height: 2),
        itemBuilder: (context, index) {
          final track = _tracks[index];
          return SearchListItem(track);
        },
      ),
    );
  }

  Widget _buildCategoriesList() => SliverAppBar(
        pinned: true,
        toolbarHeight: 55,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CategoryList(
            onTap: !_isSearching
                ? (index) => _tabController.animateTo(index,
                    curve: Easing.standard, duration: Durations.medium1)
                : null,
          ),
        ),
      );

  Widget _buildSearchbar(bool isMobile, Color outlineColor) => SliverAppBar(
        floating: true,
        pinned: !isMobile,
        toolbarHeight: 72,
        titleSpacing: AppTheme.sidePadding,
        title: TxSearchBar(
          onSearch: _handleSearch,
        ),
      );

  Future<void> _handleSearch(String query) {
    if (!mounted) return Future.value();
    _scrollController.animateTo(
      0,
      duration: Durations.medium1,
      curve: Easing.standard,
    );
    if (_error != null) {
      setState(() => _error = null);
    }
    if (query.isEmpty) {
      setState(() {
        _tracks = [];
        _query = '';
      });
      return Future.value();
    }
    return _txLoader.load(
      () => _trackService.searchTracks(query),
      ensure: () => mounted,
      onSuccess: (tracks) => setState(() {
        _tracks = tracks;
        _query = query;
      }),
    );
  }
}
