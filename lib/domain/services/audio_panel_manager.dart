import 'package:flutter/foundation.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '/main.dart';
import '/page_manager.dart';
import '/utils/get.dart';

class AudioPanelManager {
  final panelController = PanelController();
  final panelVisibility = ValueNotifier(0.0);

  late final _pageManager = Get.the<PageManager>();

  AudioPanelManager._();
  static AudioPanelManager instance = AudioPanelManager._();

  void hide() {
    panelVisibility.value = 0;
    _pageManager.stop();
  }

  void _unhide(bool dontShowPanel) {
    panelVisibility.value = 1;
    if (!dontShowPanel) {
      panelController.open();
    }
  }

  void maximizeAndPlay(bool dontShowPanel) async {
    if (MyApp.isMobile) {
      _unhide(dontShowPanel);
      while (!panelController.isAttached) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      if (!dontShowPanel) {
        panelController.open();
      }
    }
    _pageManager.play();
  }

  Future<void> minimize() => panelController.close();
}
