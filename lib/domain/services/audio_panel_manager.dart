import 'package:flutter/foundation.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

class AudioPanelManager {
  final panelController = PanelController();
  final panelVisibility = ValueNotifier(0.0);

  AudioPanelManager._();
  static AudioPanelManager instance = AudioPanelManager._();

  void showPanel(bool dontShowPanel) {
    if (panelController.isAttached) {
      panelVisibility.value = 1;
      if (!dontShowPanel) {
        panelController.open();
      }
    } else {
      panelVisibility.value = 1;
      Future.delayed(Duration(seconds: 2), () {
        if (panelController.isAttached) {
          if (!dontShowPanel) {
            panelController.open();
          }
        }
      });
    }
  }
}
