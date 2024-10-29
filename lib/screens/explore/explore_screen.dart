import 'package:animations/animations.dart';
import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';

import '/domain/models/audiofile_model.dart';
import '/domain/models/category_block.dart';
import '/domain/services/audio_panel_manager.dart';
import '/domain/services/tracks_service.dart';
import '/screens/home/category_list.dart';
import '/screens/tabs_subcategory_screen.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/utils/global_functions.dart';
import '/utils/tx_loader.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
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
  final _audioPanelManager = Get.the<AudioPanelManager>();

  final _txLoader = TxLoader();
  final _scrollController = ScrollController();
  TabController? _tabController;

  List<AudioTrack> _tracks = [];
  List<CategoryBlock> _categories = [];
  String? _error;

  String _query = '';
  bool get _isSearching => _query.isNotEmpty;

  @override
  Widget build(BuildContext context) => AppScaffold(
        resizeToAvoidBottomInset: false,
        bodyPadding: EdgeInsets.zero,
        appBar: (context, isMobile) => AdaptiveAppBar(
          title: 'Explore',
        ),
        body: (context, isMobile) {
          final colors = Theme.of(context).colorScheme;
          return NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, value) => [
              _buildSearchbar(isMobile, colors.outline),
              _buildCategoriesList(),
            ],
            body: SharedAxisSwitcher(
              disableFillColor: true,
              transitionType: SharedAxisTransitionType.scaled,
              child: _isSearching
                  ? _buildSearchView(colors)
                  : _categories.isEmpty
                      ? Center(child: Text('No categories found'))
                      : TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          controller: _tabController,
                          children: _categories
                              .map((category) => TabsSubCategoryScreen(
                                    category,
                                    key: ValueKey(category.id),
                                  ))
                              .toList(),
                        ),
            ),
          );
        },
      );

  Widget _buildSearchView(ColorScheme colors) {
    if (_error != null) return Text('Error: $_error');
    if (_txLoader.loading) {
      return Center(child: CircularProgressIndicator());
    } else if (_tracks.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CarbonIcons.search, size: 62, color: colors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: TextStyle(color: colors.onSurfaceVariant),
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
    return ListView.separated(
      itemCount: _tracks.length,
      padding: EdgeInsets.only(bottom: 150),
      cacheExtent: 1000,
      separatorBuilder: (context, index) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        final track = _tracks[index];
        return SearchListItem(
          imageUrl: track.thumbnail,
          name: track.title,
          category: track.categories.firstOrNull?.categoryName ?? '',
          duration: track.length,
          speaker: track.speaker,
          onPress: () {
            playTrack(track);
            _audioPanelManager.maximize(false);
          },
        );
      },
    );
  }

  Widget _buildCategoriesList() => SliverAppBar(
        pinned: true,
        toolbarHeight: 62,
        title: ValueListenableBuilder(
          valueListenable: indexNotifier,
          builder: (context, index, child) => CategoryList(
            selectedTabIndex: index,
            onLoad: (items) => setState(() {
              _tabController = TabController(length: items.length, vsync: this);
              _categories = items;
            }),
            onTap: _isSearching
                ? null
                : (categoryBlock) {
                    _tabController!.animateTo(_categories.indexOf(categoryBlock));
                    indexNotifier.value = _categories.indexOf(categoryBlock);
                  },
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
