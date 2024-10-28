import 'package:flutter/foundation.dart';
import 'package:sleeptales/page_manager.dart';
import 'package:sleeptales/utils/get.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

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

  void _unhide() {
    panelVisibility.value = 1;
    panelController.open();
  }

  void maximize(bool dontShowPanel) async {
    _unhide();
    while (!panelController.isAttached) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    if (!dontShowPanel) {
      panelController.open();
    }
    _pageManager.play();
  }

  void minimize() => panelController.close();
}
