import 'package:flutter/material.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '/domain/services/audio_panel_manager.dart';
import '/page_manager.dart';
import '/screens/home/app_bottom_bar.dart';
import '/screens/home/widgets/audio_panel_preview.dart';
import '/screens/music_player_screen.dart';
import '/utils/get.dart';

class SlidingPanel extends StatelessWidget {
  SlidingPanel({
    super.key,
    required this.controller,
  });

  final _panelManager = Get.the<AudioPanelManager>();
  final _pageManager = Get.the<PageManager>();

  final AnimationController controller;

  PanelController get _panelController => _panelManager.panelController;
  ValueNotifier<double> get _panelVisibility => _panelManager.panelVisibility;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ListenableBuilder(
      listenable: _panelVisibility,
      builder: (context, child) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _panelVisibility.value),
        duration: Durations.short3,
        curve: Easing.standard,
        builder: (context, value, child) => Transform.translate(
          offset: Offset(0, (1 - value) * AudioPanelPreview.height),
          child: child!,
        ),
        child: Listener(
          onPointerMove: (event) {
            if (event.delta.dy > 3 &&
                _panelController.isAttached &&
                _panelController.isPanelClosed &&
                _panelVisibility.value > 0) {
              _panelVisibility.value = 0;
            }
          },
          child: child,
        ),
      ),
      child: SlidingUpPanel(
        controller: _panelController,
        maxHeight: height,
        minHeight: bottom + AppBottomBar.height + AudioPanelPreview.height,
        color: Colors.transparent,
        onPanelSlide: (pos) => controller.value = pos,
        panelBuilder: () => Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: _pageManager.playlistNotifier,
              builder: (context, playlist, child) => MusicPlayerScreen(
                isPlaylist: playlist.length > 1,
              ),
            ),
            if (_panelController.isAttached)
              AnimatedBuilder(
                animation: controller,
                builder: (context, child) => Opacity(
                  opacity: 1 -
                      CurvedAnimation(
                        parent: controller,
                        curve: Curves.fastEaseInToSlowEaseOut,
                      ).value,
                  child: child!,
                ),
                child: AudioPanelPreview(),
              )
          ],
        ),
      ),
    );
  }
}
