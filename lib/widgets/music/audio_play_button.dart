import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/page_manager.dart';
import '/utils/get.dart';

class AudioPlayButton extends StatelessWidget {
  AudioPlayButton({super.key, this.large = false});

  final bool large;

  final _pageManager = Get.the<PageManager>();

  @override
  Widget build(BuildContext context) => IconButtonTheme(
        data: IconButtonThemeData(
          style: IconButtonTheme.of(context).style?.copyWith(
                padding: large ? WidgetStatePropertyAll(EdgeInsets.all(24)) : null,
                iconSize: large ? WidgetStatePropertyAll(32) : null,
              ),
        ),
        child: StreamBuilder(
          stream: _pageManager.listenPlaybackState(),
          builder: (_, snapshot) {
            final processingState = snapshot.data?.processingState;
            if (!snapshot.hasData ||
                processingState == AudioProcessingState.loading ||
                processingState == AudioProcessingState.buffering) {
              return IconButton(
                icon: SizedBox(
                  width: 32,
                  height: 32,
                  child: CupertinoActivityIndicator(color: Colors.white),
                ),
                onPressed: () {},
              );
            } else if (processingState == AudioProcessingState.completed) {
              return IconButton(
                icon: Icon(Icons.replay),
                onPressed: () => _pageManager.seek(Duration.zero),
              );
            } else {
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: snapshot.data!.playing ? 0 : 1),
                duration: Durations.medium2,
                curve: Easing.standard,
                builder: (context, value, child) => IconButton(
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.pause_play,
                    progress: AlwaysStoppedAnimation(value),
                  ),
                  onPressed:
                      snapshot.data!.playing ? _pageManager.pause : _pageManager.play,
                ),
              );
            }
          },
        ),
      );
}
