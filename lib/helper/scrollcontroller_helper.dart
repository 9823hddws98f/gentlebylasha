import 'package:flutter/material.dart';

class ScrollControllerHelper {
  ScrollController scrollController = ScrollController();

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }
}
