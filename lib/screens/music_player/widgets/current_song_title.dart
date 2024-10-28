import 'package:flutter/material.dart';

import '/domain/services/service_locator.dart';
import '/page_manager.dart';

class CurrentSongTitle extends StatelessWidget {
  CurrentSongTitle({super.key});

  final _pageManager = getIt<PageManager>();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
        valueListenable: _pageManager.currentSongTitleNotifier,
        builder: (_, title, __) => Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
        ),
      );
}
