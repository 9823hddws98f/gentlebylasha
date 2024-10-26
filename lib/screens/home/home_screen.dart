import 'package:app_links/app_links.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleeptales/domain/services/audio_panel_manager.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '/domain/blocs/user/app_user.dart';
import '/domain/cubits/navigation.dart';
import '/page_manager.dart';
import '/screens/music_player_screen.dart';
import '/utils/get.dart';
import '/utils/global_functions.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import 'app_bottom_bar.dart';
import 'app_side_bar.dart';
import 'widgets/music_panel_preview.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _navigationCubit = NavigationCubit();
  final _audioPanelManager = Get.the<AudioPanelManager>();

  final _allNavItems = AppNavigation.allNavItems;

  late final _audioPlayerAnimCtrl = AnimationController(
    duration: Durations.short4,
    vsync: this,
  );

  final _bottomSheetVisible = ValueNotifier<bool>(true);

  List<String> _playlist = [];
  MediaItem? _item;

  @override
  void initState() {
    super.initState();
    Get.the<PageManager>().init();
    Get.the<PageManager>().currentMediaItemNotifier.value = MediaItem(id: "", title: "");
    Get.the<PageManager>().playlistNotifier.addListener(_onPlaylistChanged);
    fetchFavoriteTracksList();
  }

  @override
  void dispose() {
    super.dispose();
    Get.the<PageManager>().currentMediaItemNotifier.removeListener(_onMediaItemChanged);
    Get.the<PageManager>().playlistNotifier.removeListener(_onPlaylistChanged);
    // TODO:  _audioPlayerAnimCtrl.dispose();
  }

  void _onPlaylistChanged() {
    setState(() {
      if (mounted) {
        _playlist = Get.the<PageManager>().playlistNotifier.value;
      }
    });
  }

  void _onMediaItemChanged() {
    setState(() {
      if (mounted) {
        _item = Get.the<PageManager>().currentMediaItemNotifier.value;
      }
    });
  }

  Future<void> fetchFavoritePlayList() async {
    AppUser user = await getUser();
    final favoritesCollection =
        FirebaseFirestore.instance.collection('favorites_playlist');
    final userFavoritesDocRef = favoritesCollection.doc(user.id);

    final favoritesDocSnapshot = await userFavoritesDocRef.get();

    if (favoritesDocSnapshot.exists) {
      final favoritesData = favoritesDocSnapshot.data();
      List<String> favorites = List.from(favoritesData!['playlist']);
      await addFavoritePlayListToSharedPref(favorites);
    }
  }

  Future<void> fetchFavoriteTracksList() async {
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

  void _hidePanel() {
    setState(() {
      _audioPanelManager.panelVisibility.value = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
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
          body: (context, isMobile) =>
              isMobile ? _buildMobile(height, bottom) : _buildDesktop(height, bottom),
        ),
      ),
    );
  }

  Widget _buildMobile(double height, double bottom) => Stack(
        children: [
          for (final item in AppNavigation.mobileNavItems)
            _buildNavigationScreen(item, true),
          _buildSlidingPanel(height, bottom),
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

  Widget _buildDesktop(double height, double bottom) => AppSideBar(
        child: Stack(
          children: AppNavigation.desktopNavItems
              .map((item) => _buildNavigationScreen(item, false))
              .toList(),
        ),
      );

  Widget _buildNavigationScreen(NavItem item, bool isMobile) {
    return BlocBuilder<NavigationCubit, NavItem>(
      builder: (context, state) {
        // HACK
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

  void _handleBadRoute(bool isMobile, NavItem state, BuildContext context) {
    if (isMobile && AppNavigation.mobileNavItems.contains(_allNavItems[state.index])) {
      return;
    } else if (!isMobile &&
        AppNavigation.desktopNavItems.contains(_allNavItems[state.index])) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<NavigationCubit>().select(_allNavItems[0]);
    });
  }

  Widget _buildSlidingPanel(double height, double bottom) =>
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _audioPanelManager.panelVisibility.value),
        duration: Durations.short3,
        curve: Easing.standard,
        builder: (context, value, child) => Transform.translate(
          offset: Offset(0, (1 - value) * MusicPanelPreview.height),
          child: child!,
        ),
        child: Listener(
          onPointerMove: (event) {
            if (event.delta.dy > 3 &&
                _audioPanelManager.panelController.isAttached &&
                _audioPanelManager.panelController.isPanelClosed &&
                _audioPanelManager.panelVisibility.value > 0) {
              _hidePanel();
            }
          },
          child: SlidingUpPanel(
            controller: _audioPanelManager.panelController,
            maxHeight: height,
            minHeight: bottom + AppBottomBar.height + 78,
            color: Colors.transparent,
            onPanelSlide: (pos) {
              _audioPlayerAnimCtrl.value = pos;
              // TODO: TEST <= or >
              _bottomSheetVisible.value = pos <= 0.08;
            },
            panelBuilder: () => Stack(
              children: [
                MusicPlayerScreen(
                  playList: _playlist.length > 1 ? true : false,
                  panelControllerNest: _audioPanelManager.panelController,
                ),
                if (_audioPanelManager.panelController.isAttached)
                  AnimatedBuilder(
                    animation: _audioPlayerAnimCtrl,
                    builder: (context, child) => Opacity(
                      opacity: 1 -
                          CurvedAnimation(
                            parent: _audioPlayerAnimCtrl,
                            curve: Curves.fastEaseInToSlowEaseOut,
                          ).value,
                      child: child!,
                    ),
                    child: MusicPanelPreview(),
                  )
              ],
            ),
          ),
        ),
      );

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
