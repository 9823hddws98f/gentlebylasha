import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';

import '/constants/language_constants.dart';

class AppBottomBar extends StatefulWidget {
  const AppBottomBar({super.key, required this.onSelect});

  static const height = 53.0;

  final Function(int) onSelect;

  @override
  State<AppBottomBar> createState() => _AppBottomBarState();
}

class _AppBottomBarState extends State<AppBottomBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tr = translation();
    final bottom = MediaQuery.paddingOf(context).bottom;
    return SizedBox(
      height: AppBottomBar.height + bottom,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
          ),
        ),
        position: DecorationPosition.foreground,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(CarbonIcons.home),
              label: tr.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(CarbonIcons.search),
              label: tr.explore,
            ),
            BottomNavigationBarItem(
              icon: const Icon(CarbonIcons.user_avatar),
              label: tr.profile,
            ),
          ],
          onTap: (index) {
            setState(() => _selectedIndex = index);
            widget.onSelect(index);
          },
        ),
      ),
    );
  }
}
