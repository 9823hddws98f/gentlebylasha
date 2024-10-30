import 'package:animations/animations.dart';
import 'package:audio_service/audio_service.dart';
import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleeptales/widgets/app_image.dart';

import '/constants/assets.dart';
import '/domain/services/audio_panel_manager.dart';
import '/main.dart';
import '/page_manager.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/widgets/shared_axis_switcher.dart';
import 'widgets/audio_progress_bar.dart';
import 'widgets/control_buttons.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final _audioPanelManager = Get.the<AudioPanelManager>();
  final _pageManager = Get.the<PageManager>();

  static final _borderRadius = BorderRadius.only(
    topLeft: AppTheme.smallBorderRadius.topLeft,
    topRight: AppTheme.smallBorderRadius.topRight,
  );

  bool _hide = false;

  void _toggleHide() => setState(() => _hide = !_hide);

  @override
  Widget build(BuildContext context) => MyApp.isMobile ? _buildMobile() : _buildDesktop();

  Widget _buildMobile() => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) => _audioPanelManager.minimize(),
        child: DecoratedBox(
          decoration: BoxDecoration(borderRadius: _borderRadius),
          child: GestureDetector(
            onTap: () => _toggleHide(),
            child: ValueListenableBuilder(
              valueListenable: _pageManager.currentMediaItemNotifier,
              builder: (context, mediaItem, child) =>
                  // TODO: Figure out why this is empty for couple of seconds
                  mediaItem.id.isNotEmpty
                      ? Stack(
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
                        )
                      : Center(
                          child: CupertinoActivityIndicator(
                            color: Colors.white,
                          ),
                        ),
            ),
          ),
        ),
      );

  Widget _buildDesktop() => ValueListenableBuilder(
        valueListenable: _pageManager.currentMediaItemNotifier,
        builder: (context, mediaItem, child) =>
            // TODO: Figure out why this is empty for couple of seconds
            mediaItem.id.isNotEmpty
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
                  )
                : Center(child: CupertinoActivityIndicator(color: Colors.white)),
      );

  Widget _buildArtwork(Uri? artUri, bool isMobile) => ClipRRect(
        borderRadius: isMobile ? _borderRadius : BorderRadius.all(Radius.circular(18)),
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
              ? AppImage(
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
      );

  Widget _buildProgressBar(MediaItem mediaItem) => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8.0),
          child: mediaItem.extras?['categories'] != 'Soundscape'
              ? AudioProgressBar()
              : SizedBox(),
        ),
      );
}