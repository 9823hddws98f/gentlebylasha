import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supa_carbon_icons/supa_carbon_icons.dart';

import '/screens/explore/explore_screen.dart';
import '/screens/favorites/favorites_screen.dart';
import '/screens/home/home_screen.dart';
import '/screens/settings/profile_settings_screen.dart';

class NavigationCubit extends Cubit<NavItem> {
  NavigationCubit() : super(AppNavigation.allNavItems[0]);

  void select(NavItem item) {
    if (state.index == item.index) {
      state.navigatorKey.currentState?.popUntil((route) => route.isFirst);
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
      icon: CarbonIcons.favorite,
      screen: FavoritesScreen(),
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
          screen != null || onTap != null,
          'Either screen or onTap must be provided',
        );
}
