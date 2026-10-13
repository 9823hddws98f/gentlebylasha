import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gentle/l10n/app_localizations.dart';

import '/domain/services/language_cubit.dart';
import '/screens/explore/explore_screen.dart';
import '/screens/favorites/favorites_screen.dart';
import '/screens/home/home_screen.dart';
import '/screens/settings/profile_settings_screen.dart';
import '/utils/get.dart';

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
      title: (tr) => tr.home,
      icon: Icons.home_outlined,
      screen: HomeScreen(),
    ),
    NavItem(
      index: 1,
      title: (tr) => tr.explore,
      icon: Icons.search_rounded,
      screen: ExploreScreen(),
    ),
    NavItem(
      index: 2,
      title: (tr) => tr.profile,
      icon: Icons.account_circle_outlined,
      screen: ProfileSettingsScreen(),
    ),
    NavItem(
      index: 3,
      title: (tr) => tr.myLibrary,
      icon: Icons.favorite_border_rounded,
      screen: FavoritesScreen(),
    ),
    NavItem(
      index: 4,
      title: (tr) => tr.more,
      icon: Icons.account_circle_outlined,
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
  final String Function(AppLocalizations tr) _title;
  final IconData icon;
  final Widget? screen;
  final VoidCallback? onTap;
  final GlobalKey<NavigatorState> navigatorKey;

  /// The label in the app language.
  String get title => _title(Get.the<LanguageCubit>().translation);

  NavItem({
    required this.index,
    required String Function(AppLocalizations tr) title,
    required this.icon,
    this.screen,
    this.onTap,
    GlobalKey<NavigatorState>? navigatorKey,
  })  : _title = title,
        navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
        assert(
          screen != null || onTap != null,
          'Either screen or onTap must be provided',
        );
}
