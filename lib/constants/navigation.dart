import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';

import '/screens/explore_screen.dart';
import '/screens/forme_screen.dart';
import '/screens/profile_settings_screen.dart';

class AppNavigation {
  static const mobileNavItems = [
    NavItem(
      index: 0,
      title: 'Home',
      icon: CarbonIcons.home,
      screen: ForMeScreen(),
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
  ];

  static final desktopNavItems = [
    NavItem(
      index: 0,
      title: 'Home',
      icon: CarbonIcons.home,
      screen: const ForMeScreen(),
    ),
    NavItem(
      index: 1,
      title: 'Explore',
      icon: CarbonIcons.search,
      screen: const ExploreScreen(),
    ),
    NavItem(
      index: 2,
      title: 'My Library',
      icon: CarbonIcons.person,
      screen: const ExploreScreen(),
    ),
    NavItem(
      index: 3,
      title: 'More',
      icon: CarbonIcons.person,
      screen: const ProfileSettingsScreen(),
    )
  ];
}

class NavItem {
  final int index;
  final String title;
  final IconData icon;
  final Widget? screen;
  final VoidCallback? onTap;

  const NavItem({
    required this.index,
    required this.title,
    required this.icon,
    this.screen,
    this.onTap,
  }) : assert(screen != null || onTap != null, 'Either screen or onTap must be provided');
}
