import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/screens/explore_screen.dart';
import '../../screens/home/home_screen.dart';
import '/screens/profile_settings_screen.dart';

class NavigationCubit extends Cubit<NavItem> {
  NavigationCubit() : super(AppNavigation.allNavItems[0]);

  void select(NavItem item) {
    if (state.index == item.index) {
      final currentNavigator =
          AppNavigation.allNavItems[state.index].navigatorKey.currentState!;
      currentNavigator.popUntil((route) => route.isFirst);
      // TODO: SEE IF NEEDED
      // _scrollControllerHelper.scrollToTop();
    }
    emit(item);
  }
}

class AppNavigation {
  static final allNavItems = [
    NavItem(
      index: 0,
      title: 'Home',
      icon: CarbonIcons.home,
      screen: HomeScreen(),
    ),
    NavItem(
      index: 1,
      title: 'Explore',
      icon: CarbonIcons.search,
      screen: ExploreScreen(),
    ),
    NavItem(
      index: 2,
      title: 'Profile',
      icon: CarbonIcons.user_avatar,
      screen: ProfileSettingsScreen(),
    ),
    NavItem(
      index: 3,
      title: 'My Library',
      icon: CarbonIcons.user_avatar,
      screen: ColoredBox(color: Colors.red, child: Center(child: Text('My Library'))),
    ),
    NavItem(
      index: 4,
      title: 'More',
      icon: CarbonIcons.user_avatar,
      screen: ProfileSettingsScreen(),
    ),
  ];

  static final mobileNavItems = [
    allNavItems[0],
    allNavItems[1],
    allNavItems[4],
  ];

  static final desktopNavItems = [
    allNavItems[0],
    allNavItems[1],
    allNavItems[3],
    allNavItems[4],
  ];
}

class NavItem {
  final int index;
  final String title;
  final IconData icon;
  final Widget? screen;
  final VoidCallback? onTap;
  final GlobalKey<NavigatorState> navigatorKey;

  NavItem({
    required this.index,
    required this.title,
    required this.icon,
    this.screen,
    this.onTap,
    GlobalKey<NavigatorState>? navigatorKey,
  })  : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
        assert(
            screen != null || onTap != null, 'Either screen or onTap must be provided');
}