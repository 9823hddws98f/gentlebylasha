import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:gentle/domain/services/deep_linking_service.dart';
import 'package:supa_carbon_icons/supa_carbon_icons.dart';

import '/domain/models/block_item/audio_track.dart';
import '/main.dart';
import '/notifiers/repeat_notifier.dart';
import '/utils/app_theme.dart';
import '/utils/common_extensions.dart';
import '/utils/get.dart';
import '/widgets/download_button.dart';
import '/widgets/music/audio_play_button.dart';
import '../../../domain/services/audio_manager.dart';
import 'current_song_title.dart';
import 'favorite_button.dart';
import 'timer_button.dart';

class ControlButtons extends StatefulWidget {
  const ControlButtons({super.key, required this.mediaItem});

  final MediaItem mediaItem;

  @override
  State<ControlButtons> createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<ControlButtons> {
  final _pageManager = Get.the<AudioManager>();
  final _deepLinkingService = Get.the<DeepLinkingService>();

  AudioTrack? get _track => widget.mediaItem.extras?['track'];
  String? get _trackId => _track?.id;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final primary = colors.primary;
    return IconButtonTheme(
      data: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: Size(45, 45),
          iconSize: 26,
          foregroundColor: colors.onSurface,
          backgroundColor: colors.surface.withValues(alpha: 0.6),
          disabledBackgroundColor: colors.surface.withValues(alpha: 0.3),
          disabledForegroundColor: colors.onSurface.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyApp.isMobile
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: Icon(CarbonIcons.arrow_left),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                )
              : SizedBox(height: 32),
          SizedBox(height: 16),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _pageManager.playlistIdNotifier,
              builder: (context, playlistIds, child) {
                final isPlaylist = playlistIds.isNotEmpty;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
                  child: Column(
                    children: [
                      Expanded(
                        child: DefaultTextStyle.merge(
                          style: TextStyle(
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                blurRadius: 10,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CurrentSongTitle(),
                              SizedBox(height: 16),
                              Expanded(
                                child: Text(
                                  widget.mediaItem.displayDescription ?? '',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_trackId != null) FavoriteButton(trackId: _trackId!),
                          _buildShareButton(),
                          if (_track?.hasTimer ?? false) TimerButton(),
                          if (isPlaylist) _buildShuffleButton(primary),
                          TrackDownloadButton(track: _track)
                        ].interleaveWith(SizedBox(width: 20)),
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildRepeatButton(primary),
                          isPlaylist ? _buildSkipBackward() : _buildSeekBackward(),
                          AudioPlayButton(large: true),
                          isPlaylist ? _buildSkipForward() : _buildSeekForward(),
                          _buildStopButton(),
                        ],
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShuffleButton(Color primary) => ValueListenableBuilder(
        valueListenable: _pageManager.isShuffleModeEnabledNotifier,
        builder: (context, isShuffleModeEnabled, child) => IconButton(
          icon: Icon(CarbonIcons.shuffle),
          color: isShuffleModeEnabled ? primary : null,
          onPressed: () => _pageManager.shuffle(),
        ),
      );

  Widget _buildSkipBackward() => ValueListenableBuilder(
        valueListenable: _pageManager.isFirstSongNotifier,
        builder: (context, isFirstSong, child) => IconButton(
          icon: Icon(CarbonIcons.skip_back_filled),
          onPressed: isFirstSong ? null : () => _pageManager.previous(),
        ),
      );

  Widget _buildSkipForward() => ValueListenableBuilder(
        valueListenable: _pageManager.isLastSongNotifier,
        builder: (context, isLastSong, child) => IconButton(
          icon: Icon(CarbonIcons.skip_forward_filled),
          onPressed: isLastSong ? null : () => _pageManager.next(),
        ),
      );

  Widget _buildSeekBackward() => IconButton(
        icon: Icon(CarbonIcons.rewind_10),
        onPressed: () => _pageManager.skipBackward(),
      );

  Widget _buildSeekForward() => IconButton(
        icon: Icon(CarbonIcons.forward_10),
        onPressed: () => _pageManager.skipForward(),
      );

  Widget _buildRepeatButton(Color primary) => ValueListenableBuilder(
        valueListenable: _pageManager.repeatButtonNotifier,
        builder: (context, repeatState, child) => IconButton(
          icon: Icon(Icons.repeat),
          color: repeatState == RepeatState.off ? null : primary,
          onPressed: () => _pageManager.repeat(),
        ),
      );

  Widget _buildStopButton() => IconButton(
        icon: Icon(CarbonIcons.stop_filled_alt),
        onPressed: () => _pageManager.stop(),
      );

  Widget _buildShareButton() => IconButton(
        icon: Icon(CarbonIcons.share),
        onPressed:
            _trackId != null ? () => _deepLinkingService.shareTrack(_trackId!) : null,
      );
}
