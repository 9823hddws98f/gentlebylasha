import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleeptales/utils/common_extensions.dart';

import '/constants/navigation.dart';

class AppBottomBar extends StatefulWidget {
  const AppBottomBar({super.key});

  static const height = 53.0;

  @override
  State<AppBottomBar> createState() => _AppBottomBarState();
}

class _AppBottomBarState extends State<AppBottomBar> {
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
          child: BlocBuilder<NavigationCubit, NavItem>(
            builder: (context, state) => BottomNavigationBar(
              currentIndex: min(AppNavigation.mobileNavItems.length - 1, state.index),
              items: AppNavigation.mobileNavItems
                  .map((e) => BottomNavigationBarItem(
                        icon: Icon(e.icon),
                        label: e.title,
                      ))
                  .toList(),
              onTap: (index) {
                context.read<NavigationCubit>().select(
                      context.isMobile
                          ? AppNavigation.mobileNavItems[index]
                          : AppNavigation.desktopNavItems[index],
                    );
              },
            ),
          ),
        ),
      );
}
