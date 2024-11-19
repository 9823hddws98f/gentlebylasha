import 'package:flutter/material.dart';
import 'package:supa_carbon_icons/supa_carbon_icons.dart';

import '/main.dart';
import '/utils/app_theme.dart';
import '/widgets/music/desktop_music_preview.dart';

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const _desktopHeight = 104.0;
  static const _mobileHeight = 68.0;
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

  @override
  Size get preferredSize => Size.fromHeight(
        (MyApp.isMobile ? _mobileHeight : _desktopHeight) +
            (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final isMobile = MyApp.isMobile;
    final canPop = Navigator.canPop(context);
    return AppBar(
      title: _buildHeader(isMobile, context, canPop),
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

  Widget _buildBackButton(BuildContext context) => IconButton(
        icon: Icon(CarbonIcons.arrow_left),
        onPressed: () => Navigator.pop(context),
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

  Widget _buildHeader(bool isMobile, BuildContext context, bool canPop) {
    const halfPadding = AppTheme.sidePadding / 2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: isMobile
          ? [
              const SizedBox(width: halfPadding),
              if (canPop) _buildBackButton(context),
              const SizedBox(width: halfPadding),
              Expanded(child: _buildTitle(true)),
            ]
          : [
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(child: _buildTitle(false)),
                    if (canPop)
                      Positioned(
                        left: halfPadding,
                        child: _buildBackButton(context),
                      ),
                    Positioned(
                      right: 0,
                      child: DesktopMusicPreview(),
                    ),
                  ],
                ),
              ),
            ],
    );
  }

  Widget _buildTitle(bool isMobile) => Text(
        title,
        style: TextStyle(
          fontSize: isMobile ? null : 32,
          fontWeight: isMobile ? null : FontWeight.w600,
        ),
      );
}
