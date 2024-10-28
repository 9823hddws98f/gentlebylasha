import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';

import '/utils/app_theme.dart';

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;

  const AdaptiveAppBar({
    super.key,
    required this.title,
    this.centerTitle = false,
    this.actions = const [],
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) => AppBar(
        title: Row(
          children: [
            const SizedBox(width: AppTheme.sidePadding / 2),
            if (Navigator.canPop(context))
              IconButton(
                icon: Icon(CarbonIcons.arrow_left),
                onPressed: () => Navigator.pop(context),
              ),
            const SizedBox(width: AppTheme.sidePadding / 2),
            Text(title),
          ],
        ),
        automaticallyImplyLeading: false,
        centerTitle: centerTitle,
        actions: actions,
        primary: true,
        bottom: bottom,
      );
}
