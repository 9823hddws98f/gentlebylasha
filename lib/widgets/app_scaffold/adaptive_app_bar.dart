import 'package:flutter/material.dart';
import 'package:supa_carbon_icons/supa_carbon_icons.dart';

import '/main.dart';
import '/utils/app_theme.dart';
import '/widgets/music/desktop_music_preview.dart';

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? centerTitle;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;
  final bool hasBottomLine;

  const AdaptiveAppBar({
    super.key,
    required this.title,
    this.centerTitle,
    this.actions = const [],
    this.bottom,
    this.hasBottomLine = true,
  });

  static const _desktopHeight = 104.0;
  static const _mobileHeight = 68.0;

  @override
  Size get preferredSize => Size.fromHeight(
        (MyApp.isMobile ? _mobileHeight : _desktopHeight) +
            (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final isMobile = MyApp.isMobile;
    return AppBar(
      title: _buildTitle(isMobile, context),
      toolbarHeight: isMobile ? _mobileHeight : _desktopHeight,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle ?? !isMobile,
      actions: [
        ...actions,
        SizedBox(width: AppTheme.sidePadding),
      ],
      primary: true,
      bottom: _buildBottom(context),
    );
  }

  Widget _buildTitle(bool isMobile, BuildContext context) => Row(
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
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? null : 32,
                      fontWeight: isMobile ? null : FontWeight.w600,
                    ),
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
      );

  PreferredSizeWidget _buildBottom(BuildContext context) => PreferredSize(
        preferredSize: Size.fromHeight(1 + (bottom?.preferredSize.height ?? 0)),
        child: hasBottomLine
            ? Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                child: bottom,
              )
            : bottom ?? SizedBox.shrink(),
      );
}
