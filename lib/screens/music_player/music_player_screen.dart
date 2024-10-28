import 'package:animations/animations.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sleeptales/notifiers/repeat_notifier.dart';
import 'package:sleeptales/screens/app_container/widgets/audio_play_button.dart';
import 'package:sleeptales/screens/music_player/widgets/current_song_title.dart';
import 'package:sleeptales/screens/timer_picker_screen.dart';
import 'package:sleeptales/utils/common_extensions.dart';
import 'package:sleeptales/utils/global_functions.dart';
import 'package:sleeptales/widgets/shared_axis_switcher.dart';

import '/constants/assets.dart';
import '/domain/services/audio_panel_manager.dart';
import '/domain/services/service_locator.dart';
import '/notifiers/progress_notifier.dart';
import '/page_manager.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/widgets/circle_icon_button.dart';
import 'widgets/favorite_button.dart';

class MusicPlayerScreen extends StatefulWidget {
  final bool isPlaylist;

  const MusicPlayerScreen({super.key, required this.isPlaylist});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final _audioPanelManager = Get.the<AudioPanelManager>();
  final _pageManager = Get.the<PageManager>();
  final _audioHandler = Get.the<AudioHandler>();

  static final _borderRadius = BorderRadius.only(
    topLeft: AppTheme.smallBorderRadius.topLeft,
    topRight: AppTheme.smallBorderRadius.topRight,
  );

  bool _timerOn = false;
  bool _hide = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // instead of popping, we just hide the player
        _audioPanelManager.minimize();
      },
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: _borderRadius),
        child: IconButtonTheme(
          data: IconButtonThemeData(
            style: IconButton.styleFrom(
              backgroundColor: colors.surface.withValues(alpha: 0.6),
              foregroundColor: colors.onSurface,
            ),
          ),
          child: GestureDetector(
            onTap: () => _toggleHide(),
            child: ValueListenableBuilder(
              valueListenable: _pageManager.currentMediaItemNotifier,
              builder: (context, mediaItem, child) =>
                  // TODO: Figure out why this is empty for couple of seconds
                  mediaItem.id.isNotEmpty
                      ? Stack(
                          children: [
                            _buildArtwork(mediaItem.artUri),
                            Column(
                              children: [
                                Expanded(
                                  child: SharedAxisSwitcher(
                                    transitionType: SharedAxisTransitionType.scaled,
                                    disableFillColor: true,
                                    reverse: !_hide,
                                    child: _hide
                                        ? SizedBox()
                                        : _buildButtonControls(mediaItem),
                                  ),
                                ),
                                _buildProgressBar(mediaItem),
                              ],
                            )
                          ],
                        )
                      : Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArtwork(Uri? artUri) => Positioned.fill(
        child: ClipRRect(
          borderRadius: _borderRadius,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: (artUri != null && artUri.toString().isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: artUri.toString(),
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                    fadeInDuration: Duration(milliseconds: 100),
                    errorWidget: (context, url, error) => Image.asset(
                      Assets.placeholderImage,
                      fit: BoxFit.cover,
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          Assets.launchScreenBackground,
                          fit: BoxFit.cover,
                          color: Colors.black.withValues(alpha: 0.3),
                          colorBlendMode: BlendMode.darken,
                        ),
                      ),
                      Icon(CarbonIcons.music, size: 100),
                    ],
                  ),
          ),
        ),
      );

  Widget _buildButtonControls(MediaItem mediaItem) => SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(CarbonIcons.arrow_left),
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CurrentSongTitle(),
                    SizedBox(height: 16),
                    Text(
                      mediaItem.displayDescription ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FavoriteButton(trackId: mediaItem.extras!['id']),
                        CircleIconButton(
                          icon: Icons.share,
                          onPressed: () => createDeepLink(mediaItem.id),
                        ),
                        if (mediaItem.extras?['categories'] != 'Sleep Story' &&
                            mediaItem.extras?['categories'] != 'Meditation') ...[
                          CircleIconButton(
                            icon: Icons.timer_outlined,
                            onPressed: () {
                              setState(() {
                                _toggleTimer();
                                pushName(context, SleepTimerScreen());
                              });
                            },
                          ),
                        ]
                      ].interleaveWith(SizedBox(width: 24)),
                    ),
                    // TODO: CLEANUP
                    SizedBox(height: 16),
                    StreamBuilder<bool>(
                      stream: _audioHandler.playbackState
                          .map((state) => state.playing)
                          .distinct(),
                      builder: (context, snapshot) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            if (mediaItem.extras?["categories"] == "Sleep Story" ||
                                mediaItem.extras?["categories"] == "Soundscape") ...[
                              SizedBox(
                                width: 32,
                                height: 32,
                              )
                            ] else if (mediaItem.extras?["categories"] == "Music" &&
                                widget.isPlaylist) ...[
                              IconButton(
                                icon: Icon(
                                  Icons.shuffle,
                                  color: getIt<PageManager>()
                                          .isShuffleModeEnabledNotifier
                                          .value
                                      ? Colors.green
                                      : Colors.white,
                                  size: 32,
                                ),
                                onPressed: () {
                                  final pageManager = getIt<PageManager>();
                                  pageManager.shuffle();
                                  setState(() {});
                                },
                              ),
                            ] else if (mediaItem.extras?["categories"] == "Music" &&
                                widget.isPlaylist == false) ...[
                              SizedBox(
                                height: 32,
                                width: 32,
                              ),
                            ] else ...[
                              IconButton(
                                icon: Icon(
                                  Icons.tune,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onPressed: () {},
                              ),
                            ],
                            if (widget.isPlaylist) ...[
                              if (_pageManager.isFirstSongNotifier.value) ...{
                                if (_pageManager.repeatButtonNotifier.value ==
                                    RepeatState.off) ...{
                                  IconButton(
                                    icon: Icon(
                                      Icons.skip_previous,
                                      color: Colors.grey,
                                      size: 32,
                                    ),
                                    onPressed: () {
                                      // final pageManager = getIt<PageManager>();
                                      // pageManager.previous();
                                    },
                                  ),
                                } else ...{
                                  IconButton(
                                    icon: Icon(
                                      Icons.skip_previous,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    onPressed: () {
                                      // final pageManager = getIt<PageManager>();
                                      _pageManager.previous();
                                    },
                                  ),
                                }
                              } else ...{
                                IconButton(
                                  icon: Icon(
                                    Icons.skip_previous,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    // final pageManager = getIt<PageManager>();
                                    _pageManager.previous();
                                  },
                                ),
                              }
                            ] else ...[
                              IconButton(
                                icon: Icon(
                                  Icons.replay_10,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onPressed: () {
                                  final pageManager = getIt<PageManager>();
                                  pageManager.skipBackward();
                                },
                              ),
                            ],
                            AudioPlayButton(large: true),
                            if (widget.isPlaylist) ...[
                              if (_pageManager.isLastSongNotifier.value) ...{
                                if (!(_pageManager.isShuffleModeEnabledNotifier.value) &&
                                    _pageManager.repeatButtonNotifier.value ==
                                        RepeatState.off) ...{
                                  IconButton(
                                    icon: Icon(
                                      Icons.skip_next,
                                      color: Colors.grey,
                                      size: 32,
                                    ),
                                    onPressed: () {},
                                  ),
                                } else ...{
                                  IconButton(
                                    icon: Icon(
                                      Icons.skip_next,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    onPressed: () {
                                      _pageManager.next();
                                    },
                                  ),
                                }
                              } else ...{
                                IconButton(
                                  icon: Icon(
                                    Icons.skip_next,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    _pageManager.next();
                                  },
                                ),
                              }
                            ] else ...[
                              IconButton(
                                icon: Icon(
                                  Icons.forward_10_outlined,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onPressed: () {
                                  final pageManager = getIt<PageManager>();
                                  pageManager.skipForward();
                                },
                              ),
                            ],
                            if (widget.isPlaylist) ...[
                              IconButton(
                                icon: Icon(
                                  getIt<PageManager>().repeatButtonNotifier.value ==
                                          RepeatState.repeatSong
                                      ? Icons.repeat_one
                                      : Icons.repeat,
                                  color:
                                      getIt<PageManager>().repeatButtonNotifier.value ==
                                              RepeatState.off
                                          ? Colors.white
                                          : Colors.green,
                                  size: 32,
                                ),
                                onPressed: () {
                                  final pageManager = getIt<PageManager>();
                                  pageManager.repeat();
                                  setState(() {});
                                },
                              ),
                            ] else if (mediaItem.extras?["categories"] ==
                                "Soundscape") ...[
                              SizedBox(
                                width: 32,
                                height: 32,
                              )
                            ] else ...[
                              IconButton(
                                icon: Icon(
                                  Icons.square,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onPressed: () {
                                  final pageManager = getIt<PageManager>();
                                  pageManager.stop();
                                },
                              ),
                            ]
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildProgressBar(MediaItem mediaItem) => Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (mediaItem.extras?["categories"] != "Soundscape") AudioProgressBar(),
            SizedBox(height: 30),
          ],
        ),
      ));

  void _toggleHide() => setState(() => _hide = !_hide);

  void _toggleTimer() => setState(() => _timerOn = !_timerOn);

  // void startTimer() {
  //   // start timer for 5 minutes
  //   _timer = Timer(Duration(seconds: 20), () {
  //     // stop playing music after 5 minutes
  //     pauseMusic();
  //   });
  //
  //   toggleTimer();
  //
  // }

  void createDeepLink(String trackId) {
    String customScheme = 'com.sleeptales.sleeptales'; // Replace with your custom scheme

    String deepLinkUrl = '$customScheme://track?id=$trackId';

    String sharedMessage = 'Check out this track: $deepLinkUrl';

    // Prepend the custom scheme with the http:// protocol
    String url = 'http://$deepLinkUrl';

    Share.share(
      sharedMessage,
      subject: 'Track',
      sharePositionOrigin: Rect.fromLTWH(0, 0, 10, 10),
    );
  }
}

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({super.key});
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: pageManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: pageManager.seek,
          baseBarColor: Colors.white.withAlpha(70),
          progressBarColor: Colors.white,
          thumbColor: Colors.white,
        );
      },
    );
  }
}
