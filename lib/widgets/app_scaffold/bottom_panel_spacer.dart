import 'package:flutter/material.dart';

import '/domain/services/audio_panel_manager.dart';
import '/main.dart';
import '/screens/app_container/app_bottom_bar.dart';
import '/utils/get.dart';
import '/widgets/music/mobile_music_preview.dart';

class BottomPanelSpacer extends StatefulWidget {
  const BottomPanelSpacer({super.key})
      : _isSliver = false,
        _child = null;

  const BottomPanelSpacer.sliver({super.key})
      : _isSliver = true,
        _child = null;

  const BottomPanelSpacer.padding({
    super.key,
    required Widget child,
  })  : _isSliver = false,
        _child = child;

  final bool _isSliver;
  final Widget? _child;

  @override
  State<BottomPanelSpacer> createState() => _BottomPanelSpacerState();
}

class _BottomPanelSpacerState extends State<BottomPanelSpacer> {
  final _panel = Get.the<AudioPanelManager>();
  static const _minHeight = AppBottomBar.height;
  static const _panelHeight = MobileMusicPreview.height;

  static const _duration = Durations.medium1;
  static const _curve = Easing.standard;

  @override
  Widget build(BuildContext context) {
    if (!MyApp.isMobile) {
      return widget._child ?? const SizedBox.shrink();
    }

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final spacer = ValueListenableBuilder(
      valueListenable: _panel.panelVisibility,
      builder: (_, value, child) => AnimatedSize(
        duration: _duration,
        curve: _curve,
        child: SizedBox(
          height: bottomPadding + _minHeight + value * _panelHeight,
        ),
      ),
    );

    if (widget._child != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: widget._child!),
          spacer,
        ],
      );
    }

    return widget._isSliver ? SliverToBoxAdapter(child: spacer) : spacer;
  }
}
