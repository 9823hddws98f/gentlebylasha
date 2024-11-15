import 'package:flutter/material.dart';
import 'package:gentle/domain/services/deep_linking_service.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supa_carbon_icons/supa_carbon_icons.dart';

import '/constants/assets.dart';
import '/domain/models/block_item/audio_playlist.dart';
import '/domain/models/block_item/audio_track.dart';
import '/domain/services/audio_panel_manager.dart';
import '/domain/services/tracks_service.dart';
import '/screens/music_player/widgets/favorite_button.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/utils/tx_loader.dart';
import '/widgets/app_image.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';
import '/widgets/user_avatar.dart';
import '../../domain/services/audio_manager.dart';

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
  final _pageManager = Get.the<AudioManager>();
  final _tracksService = Get.the<TracksService>();
  late final _audioPanelManager = Get.the<AudioPanelManager>();
  late final _deepLinkingService = Get.the<DeepLinkingService>();

  final _scrollController = ScrollController();

  final _txLoader = TxLoader();
  String? _error;
  List<AudioTrack> _tracks = [];

  /// Whether this playlist is currently playing
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _fetchTracks();
    _onPlaylistBlockChange();
    _pageManager.currentPlaylistBlockNotifier.addListener(_onPlaylistBlockChange);
  }

  void _onPlaylistBlockChange() {
    if (!mounted) return;
    setState(() => _isPlaying = _pageManager.currentPlaylistBlockNotifier.value != null);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageManager.currentPlaylistBlockNotifier.removeListener(_onPlaylistBlockChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dominantColor = Color.lerp(
      widget.playlist.dominantColor ?? colors.surfaceContainerLowest,
      colors.surfaceContainerLowest,
      colors.brightness == Brightness.light ? 0.4 : 0.0,
    );
    return AppScaffold(
      bodyPadding: EdgeInsets.zero,
      body: (context, isMobile) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [dominantColor!, colors.surfaceContainerLowest],
            stops: [0, 0.8],
          ),
        ),
        child: BottomPanelSpacer.padding(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildThumbnail(dominantColor),
              _buildInfoCard(colors),
              _error != null
                  ? _buildErrorHint(colors)
                  : SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: AppTheme.sidePadding) +
                          const EdgeInsets.only(bottom: 16),
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
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () =>
                        _deepLinkingService.sharePlaylist(widget.playlist.id),
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
              _buildPlayButton(colors),
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

  Widget _buildPlayButton(ColorScheme colors) => FilledButtonTheme(
        data: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor:
                _tracks.isEmpty ? colors.outline : colors.surfaceContainerHigh,
            foregroundColor: colors.onSurface,
            iconColor: colors.onSurface,
            iconSize: 24,
            minimumSize: Size(double.infinity, 48),
          ),
        ),
        child: ValueListenableBuilder(
          valueListenable: _pageManager.playlistIdNotifier,
          builder: (context, playlistIds, child) => StreamBuilder(
            stream: _pageManager.listenPlaybackState(),
            builder: (context, snapshot) {
              final isPlaying = _isPlaying && snapshot.data?.playing == true;
              return FilledButton.icon(
                label: Text(isPlaying ? 'Pause' : 'Play'),
                icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                onPressed: () {
                  if (_isPlaying) {
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

  Widget _buildThumbnail(Color color) => SliverAppBar(
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
        backgroundColor: color,
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
          child: ValueListenableBuilder(
              valueListenable: _pageManager.currentMediaItemNotifier,
              builder: (context, mediaItem, child) {
                return InkWell(
                  onTap: () {
                    if (mediaItem.id == widget.playlist.trackIds[index] && _isPlaying) {
                      _audioPanelManager.maximizeAndPlay(false);
                    } else {
                      _pageManager.loadPlaylist(widget.playlist, _tracks, index);
                      _audioPanelManager.maximizeAndPlay(false);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh.withAlpha(100),
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
                );
              }),
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
