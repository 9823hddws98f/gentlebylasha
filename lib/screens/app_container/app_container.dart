import 'package:app_links/app_links.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/domain/blocs/user/app_user.dart';
import '/domain/cubits/navigation.dart';
import '/page_manager.dart';
import '/utils/get.dart';
import '/utils/global_functions.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import 'app_bottom_bar.dart';
import 'app_side_bar.dart';
import 'widgets/sliding_panel.dart';

class AppContainer extends StatefulWidget {
  static const routeName = '/dashboard';

  const AppContainer({super.key});

  @override
  AppContainerState createState() => AppContainerState();
}

class AppContainerState extends State<AppContainer> with SingleTickerProviderStateMixin {
  final _navigationCubit = NavigationCubit();
  final _allNavItems = AppNavigation.allNavItems;

  late final _audioPlayerAnimCtrl = AnimationController(
    duration: Durations.short4,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    Get.the<PageManager>().init();
    Get.the<PageManager>().currentMediaItemNotifier.value = MediaItem(id: '', title: '');
    _fetchFavoriteTracksList();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // TODO:  _audioPlayerAnimCtrl.dispose();
  // }

  // TODO: Favorite playlist
  // Future<void> _fetchFavoritePlayList() async {
  //   AppUser user = await getUser();
  //   final favoritesCollection =
  //       FirebaseFirestore.instance.collection('favorites_playlist');
  //   final userFavoritesDocRef = favoritesCollection.doc(user.id);

  //   final favoritesDocSnapshot = await userFavoritesDocRef.get();

  //   if (favoritesDocSnapshot.exists) {
  //     final favoritesData = favoritesDocSnapshot.data();
  //     List<String> favorites = List.from(favoritesData!['playlist']);
  //     await addFavoritePlayListToSharedPref(favorites);
  //   }
  // }

  Future<void> _fetchFavoriteTracksList() async {
    AppUser user = await getUser();
    final favoritesCollection = FirebaseFirestore.instance.collection('favorites');
    final userFavoritesDocRef = favoritesCollection.doc(user.id);

    final favoritesDocSnapshot = await userFavoritesDocRef.get();

    if (favoritesDocSnapshot.exists) {
      final favoritesData = favoritesDocSnapshot.data();
      List<String> favorites = List.from(favoritesData!['favorites']);
      await addFavoriteListToSharedPref(favorites);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return BlocProvider.value(
      value: _navigationCubit,
      child: WillPopScope(
        onWillPop: () async {
          // TODO: FIX
          // final currentNavigator =
          //     AppNavigation.allNavItems[_navigationCubit.state.index].navigatorKey.currentState!;
          // if (currentNavigator.canPop()) {
          //   currentNavigator.pop();
          //   return false;
          // } else {
          //   if (panelController.isAttached) {
          //     if (panelController.isPanelOpen) {
          //       panelController.close();
          //       return false;
          //     }
          //   }
          // }
          return true;
        },
        child: AppScaffold(
          bodyPadding: EdgeInsets.zero,
          body: (context, isMobile) => isMobile ? _buildMobile(bottom) : _buildDesktop(),
        ),
      ),
    );
  }

  Widget _buildMobile(double bottom) => Stack(
        children: [
          for (final item in AppNavigation.mobileNavItems)
            _buildNavigationScreen(item, true),
          _buildSlidingPanel(),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedBuilder(
              animation: _audioPlayerAnimCtrl,
              builder: (context, child) => Transform.translate(
                offset: Offset(
                  0,
                  _audioPlayerAnimCtrl.value * (AppBottomBar.height + bottom),
                ),
                child: child,
              ),
              child: AppBottomBar(),
            ),
          )
        ],
      );

  Widget _buildDesktop() => AppSideBar(
        child: Stack(
          children: AppNavigation.desktopNavItems
              .map((item) => _buildNavigationScreen(item, false))
              .toList(),
        ),
      );

  Widget _buildSlidingPanel() => SlidingPanel(controller: _audioPlayerAnimCtrl);

  Widget _buildNavigationScreen(NavItem item, bool isMobile) {
    return BlocBuilder<NavigationCubit, NavItem>(
      builder: (context, state) {
        _handleBadRoute(isMobile, state, context);
        return Offstage(
          offstage: state.index != item.index,
          child: Navigator(
            key: item.navigatorKey,
            onGenerateRoute: (routeSettings) => MaterialPageRoute(
              builder: (context) => item.screen!,
            ),
          ),
        );
      },
    );
  }

  // HACK
  void _handleBadRoute(bool isMobile, NavItem state, BuildContext context) {
    if (isMobile && AppNavigation.mobileNavItems.contains(_allNavItems[state.index]) ||
        !isMobile && AppNavigation.desktopNavItems.contains(_allNavItems[state.index])) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<NavigationCubit>().select(_allNavItems[0]);
    });
  }

  void initDeepLinking() async {
    // Platform messages are asynchronous, so we initialize in an async method.
    try {
      // Request permission to handle incoming links
      final appLinks = AppLinks();
      appLinks.uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          handleDeepLink(uri);
        }
      });
    } on PlatformException {
      showToast("Deeplink exception");
    }
  }

  void handleDeepLink(Uri uri) {
    String trackId = uri.queryParameters['trackId'] ?? '';
    showToast(trackId);
  }
}
