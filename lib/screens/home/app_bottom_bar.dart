import 'package:flutter/material.dart';
import 'package:sleeptales/constants/navigation.dart';

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
  Widget build(BuildContext context) => SizedBox(
        height: AppBottomBar.height + MediaQuery.paddingOf(context).bottom,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
            ),
          ),
          position: DecorationPosition.foreground,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            items: AppNavigation.mobileNavItems
                .map((e) => BottomNavigationBarItem(
                      icon: Icon(e.icon),
                      label: e.title,
                    ))
                .toList(),
            onTap: (index) {
              setState(() => _selectedIndex = index);
              widget.onSelect(index);
            },
          ),
        ),
      );
}
