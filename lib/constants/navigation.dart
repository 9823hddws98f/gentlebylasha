import 'package:flutter/material.dart';

import '/screens/explore_screen.dart';
import '/screens/forme_screen.dart';
import '/screens/profile_settings_screen.dart';

class AppNavigation {
  static const mobileNavItems = [
    NavItem(index: 0, title: 'For Me', icon: Icons.person, screen: ForMeScreen()),
    NavItem(index: 1, title: 'Explore', icon: Icons.explore, screen: ExploreScreen()),
    NavItem(
        index: 2, title: 'Profile', icon: Icons.person, screen: ProfileSettingsScreen()),
  ];

  static const desktopNavItems = [
    NavItem(index: 0, title: 'Home', icon: Icons.home, screen: ForMeScreen()),
    NavItem(index: 1, title: 'Explore', icon: Icons.explore, screen: ExploreScreen()),
    NavItem(index: 2, title: 'My Library', icon: Icons.person, screen: ExploreScreen()),
    NavItem(index: 3, title: 'More', icon: Icons.person, screen: ProfileSettingsScreen()),
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
