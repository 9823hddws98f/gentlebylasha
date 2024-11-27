import 'package:flutter/material.dart';

import '/domain/models/app_page/app_page_config.dart';

class PageConfig extends InheritedWidget {
  final AppPageConfig config;

  const PageConfig({
    super.key,
    required this.config,
    required super.child,
  });

  @override
  bool updateShouldNotify(PageConfig oldWidget) => config != oldWidget.config;

  static AppPageConfig of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PageConfig>()!.config;
}
