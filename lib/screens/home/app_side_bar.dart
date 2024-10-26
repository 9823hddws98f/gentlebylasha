import 'dart:math';
import 'dart:ui';

import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleeptales/constants/assets.dart';

class AppSideBar extends StatefulWidget {
  const AppSideBar({super.key, required this.onSelect, required this.child});

  final void Function(int) onSelect;
  final Widget child;

  @override
  State<AppSideBar> createState() => _AppSideBarState();
}

class _AppSideBarState extends State<AppSideBar> {
  static const _mainItems = [
    {'icon': CarbonIcons.home, 'title': 'Home'},
    {'icon': CarbonIcons.search, 'title': 'Explore'},
    {'icon': CarbonIcons.user_avatar, 'title': 'My Library'},
    {'icon': CarbonIcons.timer, 'title': 'Meditation'},
  ];

  static const _secondaryItems = [
    {'icon': CarbonIcons.user_avatar, 'title': 'More'},
    {'icon': CarbonIcons.help, 'title': 'Customer Support'},
    {'icon': CarbonIcons.logout, 'title': 'Logout'},
  ];

  static const _duration = Durations.medium4;

  bool _isExpanded = true;
  int _selectedIndex = 0;

  void _select(int index) {
    setState(() => _selectedIndex = index);
    widget.onSelect(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Row(
          children: [
            TweenAnimationBuilder(
              duration: _duration,
              tween: Tween<double>(begin: 1, end: _isExpanded ? 1 : 0),
              curve: Easing.standard,
              builder: (context, animation, child) => Container(
                color: theme.colorScheme.surface,
                width: lerpDouble(70, 240, animation),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 24),
                    Opacity(
                      opacity: animation,
                      child: SvgPicture.asset(Assets.logo),
                    ),
                    SizedBox(height: 24),
                    Divider(),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsetsTween(
                        begin: const EdgeInsets.symmetric(horizontal: 8),
                        end: const EdgeInsets.symmetric(horizontal: 15),
                      ).transform(animation),
                      child: Column(
                        children: List.generate(
                          _mainItems.length,
                          (index) => _buildButton(
                            index,
                            label: _mainItems[index]['title'] as String,
                            icon: _mainItems[index]['icon'] as IconData,
                            selected: _selectedIndex == index,
                            colorScheme: theme.colorScheme,
                            animation: animation,
                            onPressed: () => _select(index),
                          ),
                        ),
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: EdgeInsetsTween(
                        begin: const EdgeInsets.symmetric(horizontal: 8),
                        end: const EdgeInsets.symmetric(horizontal: 15),
                      ).transform(animation),
                      child: Column(
                        children: List.generate(
                          _secondaryItems.length,
                          (index) => _buildButton(
                            index,
                            label: _secondaryItems[index]['title'] as String,
                            icon: _secondaryItems[index]['icon'] as IconData,
                            selected: _mainItems.length + index == _selectedIndex,
                            colorScheme: theme.colorScheme,
                            animation: animation,
                            onPressed: () => _select(_mainItems.length + index),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: widget.child,
            ),
          ],
        ),
        TweenAnimationBuilder(
          duration: _duration,
          tween: Tween<double>(begin: 1, end: _isExpanded ? 1 : 0),
          curve: Easing.standard,
          builder: (context, animation, child) => Padding(
            padding: EdgeInsets.only(left: lerpDouble(15, 220, animation)!, top: 30),
            child: Transform.rotate(
              angle: lerpDouble(0, pi, animation)!,
              child: child!,
            ),
          ),
          child: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              side: BorderSide(color: theme.colorScheme.outline),
            ),
            icon: const Icon(CarbonIcons.chevron_right),
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    int index, {
    required String label,
    required IconData icon,
    required bool selected,
    required ColorScheme colorScheme,
    required double animation,
    required void Function() onPressed,
  }) =>
      Container(
        height: 60,
        margin: const EdgeInsets.only(bottom: 16),
        child: FilledButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: selected ? colorScheme.primary : colorScheme.surface,
            foregroundColor: selected ? colorScheme.onPrimary : colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            children: [
              Icon(icon),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Opacity(
                    opacity: animation,
                    child: Text(
                      label,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
