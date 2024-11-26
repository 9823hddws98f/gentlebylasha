import 'package:animations/animations.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/domain/models/block_item/audio_track.dart';
import '/domain/services/audio_manager.dart';
import '/main.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/utils/tx_image.dart';
import '/widgets/app_image.dart';
import '/widgets/shared_axis_switcher.dart';
import 'widgets/audio_progress_bar.dart';
import 'widgets/control_buttons.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final _pageManager = Get.the<AudioManager>();

  static final _borderRadius = BorderRadius.only(
    topLeft: AppTheme.smallBorderRadius.topLeft,
    topRight: AppTheme.smallBorderRadius.topRight,
  );

  bool _hide = false;

  void _toggleHide() => setState(() => _hide = !_hide);

  @override
  Widget build(BuildContext context) => MyApp.isMobile ? _buildMobile() : _buildDesktop();

  Widget _buildMobile() => DecoratedBox(
        decoration: BoxDecoration(borderRadius: _borderRadius),
        child: GestureDetector(
          onTap: () => _toggleHide(),
          child: ValueListenableBuilder(
              valueListenable: _pageManager.currentMediaItemNotifier,
              builder: (context, mediaItem, child) {
                final track = mediaItem.extras?['track'] as AudioTrack?;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildArtwork(track?.imageBackground, true),
                    SafeArea(
                      child: Column(
                        children: [
                          Expanded(
                            child: SharedAxisSwitcher(
                              transitionType: SharedAxisTransitionType.scaled,
                              disableFillColor: true,
                              reverse: !_hide,
                              child: _hide
                                  ? SizedBox()
                                  : ControlButtons(mediaItem: mediaItem),
                            ),
                          ),
                          _buildProgressBar(mediaItem),
                        ],
                      ),
                    )
                  ],
                );
              }),
        ),
      );

  Widget _buildDesktop() => ValueListenableBuilder(
      valueListenable: _pageManager.currentMediaItemNotifier,
      builder: (context, mediaItem, child) {
        final track = mediaItem.extras?['track'] as AudioTrack;
        return mediaItem.id.isNotEmpty
            ? Row(
                children: [
                  Expanded(child: _buildArtwork(track.imageBackground, false)),
                  SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: SharedAxisSwitcher(
                            transitionType: SharedAxisTransitionType.scaled,
                            disableFillColor: true,
                            reverse: !_hide,
                            child:
                                _hide ? SizedBox() : ControlButtons(mediaItem: mediaItem),
                          ),
                        ),
                        _buildProgressBar(mediaItem),
                      ],
                    ),
                  )
                ],
              )
            : Center(child: CupertinoActivityIndicator(color: Colors.white));
      });

  Widget _buildArtwork(TxImage? image, bool isMobile) {
    if (image == null) return SizedBox();
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: isMobile ? _borderRadius : BorderRadius.all(Radius.circular(18)),
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
      child: AppImage(
        image: image,
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        borderRadius: isMobile ? _borderRadius : BorderRadius.all(Radius.circular(18)),
      ),
    );
  }

  Widget _buildProgressBar(MediaItem mediaItem) => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8.0),
          child: AudioProgressBar(),
        ),
      );
}
