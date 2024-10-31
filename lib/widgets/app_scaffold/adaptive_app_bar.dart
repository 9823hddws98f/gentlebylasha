import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';

import '/main.dart';
import '/utils/app_theme.dart';
import '/widgets/music/desktop_music_preview.dart';

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? centerTitle;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;

  const AdaptiveAppBar({
    super.key,
    required this.title,
    this.centerTitle,
    this.actions = const [],
    this.bottom,
  });

  static const _desktopHeight = 104.0;
  static const _mobileHeight = 56.0;

  @override
  Size get preferredSize => Size.fromHeight(
        (MyApp.isMobile ? _mobileHeight : _desktopHeight) +
            (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final isMobile = MyApp.isMobile;
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: isMobile
            ? [
                const SizedBox(width: AppTheme.sidePadding / 2),
                if (Navigator.canPop(context))
                  IconButton(
                    icon: Icon(CarbonIcons.arrow_left),
                    onPressed: () => Navigator.pop(context),
                  ),
                const SizedBox(width: AppTheme.sidePadding / 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? null : 32,
                    fontWeight: isMobile ? null : FontWeight.w600,
                  ),
                ),
              ]
            : [
                Expanded(
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: isMobile ? null : 32,
                            fontWeight: isMobile ? null : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (Navigator.canPop(context))
                        Positioned(
                          left: AppTheme.sidePadding / 2,
                          child: IconButton(
                            icon: Icon(CarbonIcons.arrow_left),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      if (!isMobile)
                        Positioned(
                          right: 0,
                          child: DesktopMusicPreview(),
                        ),
                    ],
                  ),
                ),
              ],
      ),
      toolbarHeight: isMobile ? _mobileHeight : _desktopHeight,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle ?? !isMobile,
      actions: [
        ...actions,
        SizedBox(width: AppTheme.sidePadding),
      ],
      primary: true,
      bottom: bottom,
    );
  }
}
