import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '/constants/assets.dart';
import '/domain/models/block_item/audio_playlist.dart';
import '/domain/models/block_item/audio_track.dart';
import '/domain/services/audio_panel_manager.dart';
import '/domain/services/tracks_service.dart';
import '/page_manager.dart';
import '/screens/music_player/widgets/favorite_button.dart';
import '/utils/app_theme.dart';
import '/utils/colors.dart';
import '/utils/get.dart';
import '/utils/tx_loader.dart';
import '/widgets/app_image.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/user_avatar.dart';

class PlayListTracksScreen extends StatefulWidget {
  final AudioPlaylist playlist;

  const PlayListTracksScreen({
    super.key,
    required this.playlist,
  });

  @override
  State<PlayListTracksScreen> createState() => _PlayListTracksScreenState();
}

class _PlayListTracksScreenState extends State<PlayListTracksScreen> {
  final _pageManager = Get.the<PageManager>();
  final _tracksService = Get.the<TracksService>();
  final _audioPanelManager = Get.the<AudioPanelManager>();

  final _txLoader = TxLoader();
  String? _error;

  List<AudioTrack> _tracks = [];

  bool get _currentPlaylistIsPlaying {
    final playlistIds = _pageManager.playlistIdNotifier.value;
    if (playlistIds.length <= 1) return false;
    for (var i = 0; i < playlistIds.length - 1; i++) {
      if (playlistIds[i] != widget.playlist.trackIds[i]) return false;
    }
    return true;
  }

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchTracks();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppScaffold(
      bodyPadding: EdgeInsets.zero,
      body: (context, isMobile) => DecoratedBox(
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
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildThumbnail(),
            _buildInfoCard(colors),
            _error != null
                ? _buildErrorHint(colors)
                : SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: AppTheme.sidePadding) +
                        const EdgeInsets.only(bottom: 150),
                    sliver: SliverList.separated(
                      itemCount: _tracks.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _buildTrackItem(
                        _tracks[index],
                        index,
                        colors,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorHint(ColorScheme colors) => SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.warning_2,
                  size: 48,
                  color: colors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.error,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _fetchTracks,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildInfoCard(ColorScheme colors) => SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.sidePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.playlist.title,
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                    ),
                  ),
                  FavoriteButton(playlistId: widget.playlist.id)
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  UserAvatar(
                    imageUrl: widget.playlist.authorImage,
                    radius: 20,
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.playlist.author),
                      Text(
                        widget.playlist.profession,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildPlayButton(),
              SizedBox(height: 16),
              Text(
                widget.playlist.description,
                overflow: TextOverflow.ellipsis,
                maxLines: 9,
              ),
            ],
          ),
        ),
      );

  Widget _buildPlayButton() => FilledButtonTheme(
        data: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _tracks.isEmpty ? Colors.grey : Colors.white,
            foregroundColor: _tracks.isEmpty ? Colors.black12 : textColor,
            iconColor: _tracks.isEmpty ? Colors.black12 : textColor,
            iconSize: 24,
            minimumSize: Size(double.infinity, 48),
          ),
        ),
        child: ValueListenableBuilder(
          valueListenable: _pageManager.playlistIdNotifier,
          builder: (context, playlistId, child) => StreamBuilder(
            stream: _pageManager.listenPlaybackState(),
            builder: (context, snapshot) {
              final isPlaying =
                  _currentPlaylistIsPlaying && snapshot.data?.playing == true;
              return FilledButton.icon(
                label: Text(isPlaying ? 'Pause' : 'Play'),
                icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                onPressed: () {
                  if (_currentPlaylistIsPlaying) {
                    isPlaying
                        ? _pageManager.pause()
                        : _audioPanelManager.maximizeAndPlay(true);
                  } else {
                    _pageManager.loadPlaylist(widget.playlist, _tracks, 0);
                    _audioPanelManager.maximizeAndPlay(false);
                  }
                },
              );
            },
          ),
        ),
      );

  Widget _buildThumbnail() => SliverAppBar(
        expandedHeight: 200,
        floating: false,
        pinned: true,
        stretch: true,
        title: AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) => Opacity(
            opacity: ((_scrollController.offset - 150) / 50.0).clamp(0.0, 1.0),
            child: child,
          ),
          child: Text(
            widget.playlist.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(CarbonIcons.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: false,
          stretchModes: const [StretchMode.zoomBackground],
          background: AppImage(
            imageUrl: widget.playlist.thumbnail,
            fit: BoxFit.cover,
            placeholderAsset: Assets.placeholderImage,
          ),
        ),
      );

  Widget _buildTrackItem(AudioTrack track, int index, ColorScheme colors) => Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          height: 68,
          child: InkWell(
            onTap: () {
              _pageManager.loadPlaylist(widget.playlist, _tracks, index);
              _audioPanelManager.maximizeAndPlay(false);
            },
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.outline),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    if (widget.playlist.showAudioThumbnails)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AppImage(
                          height: 48,
                          width: 48,
                          fit: BoxFit.cover,
                          imageUrl: track.thumbnail,
                          borderRadius: AppTheme.smallImageBorderRadius,
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            track.title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            track.durationString,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FavoriteButton(
                      trackId: track.id,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Future<void> _fetchTracks() => _txLoader.load(
        onStart: () => _error != null ? setState(() => _error = null) : null,
        () => _tracksService.getByIds(widget.playlist.trackIds),
        ensure: () => mounted,
        onSuccess: (tracks) => setState(() => _tracks = tracks),
        onError: (error) => setState(() => _error = error.toString()),
      );
}
