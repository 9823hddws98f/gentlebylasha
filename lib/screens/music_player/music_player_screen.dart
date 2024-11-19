import 'package:animations/animations.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/constants/assets.dart';
import '/domain/services/audio_manager.dart';
import '/main.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
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

  // Used to avoid showing placeholder asset multiple times
  Uri? _lastArtworkUri;

  void _toggleHide() => setState(() => _hide = !_hide);

  @override
  Widget build(BuildContext context) => MyApp.isMobile ? _buildMobile() : _buildDesktop();

  Widget _buildMobile() => DecoratedBox(
        decoration: BoxDecoration(borderRadius: _borderRadius),
        child: GestureDetector(
          onTap: () => _toggleHide(),
          child: ValueListenableBuilder(
              valueListenable: _pageManager.currentMediaItemNotifier,
              builder: (context, mediaItem, child) => Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildArtwork(mediaItem.artUri, true),
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
                  )),
        ),
      );

  Widget _buildDesktop() => ValueListenableBuilder(
        valueListenable: _pageManager.currentMediaItemNotifier,
        builder: (context, mediaItem, child) => mediaItem.id.isNotEmpty
            ? Row(
                children: [
                  Expanded(child: _buildArtwork(mediaItem.artUri, false)),
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
            : Center(child: CupertinoActivityIndicator(color: Colors.white)),
      );

  Widget _buildArtwork(Uri? artUri, bool isMobile) {
    if (_lastArtworkUri != artUri) {
      _lastArtworkUri = artUri;
    }
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
        imageUrl: artUri?.toString() ?? '',
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        fadeInDuration: Durations.short2,
        borderRadius: isMobile ? _borderRadius : BorderRadius.all(Radius.circular(18)),
        placeholderAsset: _lastArtworkUri == null ? Assets.launchScreenBackground : null,
        placeholderUri: _lastArtworkUri,
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
