import 'package:app_links/app_links.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '/constants/navigation.dart';
import '/domain/blocs/user/app_user.dart';
import '/domain/services/service_locator.dart';
import '/helper/scrollcontroller_helper.dart';
import '/notifiers/play_button_notifier.dart';
import '/notifiers/progress_notifier.dart';
import '/page_manager.dart';
import '/screens/music_player_screen.dart';
import '/utils/colors.dart';
import '/utils/global_functions.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import 'app_bottom_bar.dart';
import 'app_side_bar.dart';
import 'music_panel_preview.dart';

PanelController panelController = PanelController();

class HomeScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final _audioPlayerAnimCtrl = AnimationController(
    duration: Durations.short4,
    vsync: this,
  );

  int _selectedIndex = 0;

  List<String> playlist = [];
  MediaItem? item;
  final ScrollControllerHelper _scrollControllerHelper = ScrollControllerHelper();
  ValueNotifier<bool> bottomSheetVisible = ValueNotifier<bool>(true);
  bool gestureCheck = false;
  double panelVisibility = 0;
  late List<GlobalKey<NavigatorState>> _navigatorKeys;

  final _panelKey = GlobalKey();

  void _selectScreen(int index) {
    setState(() {
      if (_selectedIndex == index) {
        final currentNavigator = _navigatorKeys[_selectedIndex].currentState!;
        currentNavigator.popUntil((route) => route.isFirst);
        _scrollControllerHelper.scrollToTop();
      }
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _navigatorKeys = List.generate(
        AppNavigation.desktopNavItems.length, (_) => GlobalKey<NavigatorState>());
    getIt<PageManager>().init();
    getIt<PageManager>().currentMediaItemNotifier.value = MediaItem(id: "", title: "");
    getIt<PageManager>().playlistNotifier.addListener(_onPlaylistChanged);
    fetchFavoriteTracksList();
  }

  @override
  void dispose() {
    super.dispose();
    getIt<PageManager>().currentMediaItemNotifier.removeListener(_onMediaItemChanged);
    getIt<PageManager>().playlistNotifier.removeListener(_onPlaylistChanged);
    // TODO:  _audioPlayerAnimCtrl.dispose();
  }

  void openExploreTab() {
    _selectScreen(1);
    setState(() {});
  }

  void showPanel(bool dontShowPanel) {
    debugPrint("panel function parameter $dontShowPanel");
    if (panelController.isAttached) {
      panelVisibility = 1;
      if (!dontShowPanel) {
        panelController.open();
      }
    } else {
      panelVisibility = 1;
      Future.delayed(Duration(seconds: 2), () {
        if (panelController.isAttached) {
          if (!dontShowPanel) {
            panelController.open();
          }
        }
      });
    }
    setState(() {});
  }

  void _onPlaylistChanged() {
    setState(() {
      if (mounted) {
        playlist = getIt<PageManager>().playlistNotifier.value;
      }
    });
  }

  void _onMediaItemChanged() {
    setState(() {
      if (mounted) {
        item = getIt<PageManager>().currentMediaItemNotifier.value;
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
      panelVisibility = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return WillPopScope(
      onWillPop: () async {
        // TODO: FIX
        final NavigatorState currentNavigator =
            _navigatorKeys[_selectedIndex].currentState!;
        if (currentNavigator.canPop()) {
          currentNavigator.pop();
          return false;
        } else {
          if (panelController.isAttached) {
            if (panelController.isPanelOpen) {
              panelController.close();
              return false;
            }
          }
        }
        return true;
      },
      child: AppScaffold(
        bodyPadding: EdgeInsets.zero,
        body: (context, isMobile) =>
            isMobile ? _buildMobile(height, bottom) : _buildDesktop(height, bottom),
      ),
    );
  }

  Widget _buildMobile(double height, double bottom) => Stack(
        children: [
          for (final item in AppNavigation.mobileNavItems)
            _buildNavigationScreen(item, item.index),
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
              child: AppBottomBar(onSelect: _selectScreen),
            ),
          )
        ],
      );

  Widget _buildDesktop(double height, double bottom) => AppSideBar(
        onSelect: _selectScreen,
        child: Stack(
          children: AppNavigation.desktopNavItems
              .map((item) => _buildNavigationScreen(item, item.index))
              .toList(),
        ),
      );

  Widget _buildSlidingPanel(double height, double bottom) =>
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: panelVisibility),
        duration: Durations.short3,
        curve: Easing.standard,
        builder: (context, value, child) => Transform.translate(
          offset: Offset(0, (1 - value) * MusicPanelPreview.height),
          child: child!,
        ),
        child: Listener(
          onPointerMove: (event) {
            if (event.delta.dy > 3 &&
                panelController.isAttached &&
                panelController.isPanelClosed &&
                panelVisibility > 0) {
              _hidePanel();
            }
          },
          child: SlidingUpPanel(
            key: _panelKey,
            maxHeight: height,
            minHeight: bottom + AppBottomBar.height + 78,
            controller: panelController,
            onPanelSlide: (pos) {
              _audioPlayerAnimCtrl.value = pos;
              if (pos > 0.08) {
                bottomSheetVisible.value = false;
              } else {
                bottomSheetVisible.value = true;
              }
            },
            panelBuilder: () => Stack(
              children: [
                MusicPlayerScreen(
                  playList: playlist.length > 1 ? true : false,
                  panelControllerNest: panelController,
                ),
                if (panelController.isAttached)
                  AnimatedBuilder(
                    animation: _audioPlayerAnimCtrl,
                    builder: (context, child) => Opacity(
                      opacity: 1 -
                          CurvedAnimation(
                                  parent: _audioPlayerAnimCtrl,
                                  curve: Curves.fastEaseInToSlowEaseOut)
                              .value,
                      child: child!,
                    ),
                    child: MusicPanelPreview(),
                  )
              ],
            ),
            color: Colors.transparent,
          ),
        ),
      );

  Widget _buildNavigationScreen(NavItem item, int index) => Offstage(
        offstage: _selectedIndex != index,
        child: Navigator(
          key: _navigatorKeys[index],
          onGenerateRoute: (routeSettings) => MaterialPageRoute(
            builder: (context) => item.screen!,
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

class PlayButtonNew extends StatelessWidget {
  const PlayButtonNew({super.key});
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ButtonState>(
      valueListenable: pageManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: EdgeInsets.all(8),
              height: 24,
              width: 24,
              child: const CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          case ButtonState.paused:
            return IconButton(
              icon: const Icon(Icons.play_arrow),
              iconSize: 24,
              onPressed: pageManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: const Icon(Icons.pause),
              iconSize: 24,
              onPressed: pageManager.pause,
            );
        }
      },
    );
  }
}

class AudioProgressBarHome extends StatelessWidget {
  const AudioProgressBarHome({super.key});
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: pageManager.progressNotifier,
      builder: (_, value, __) {
        return SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbColor: Colors.white,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0),
              overlayColor: Colors.white.withAlpha(32),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
              activeTrackColor: Colors.white,
              inactiveTrackColor: transparentWhite,
            ),
            child: Padding(
                padding: EdgeInsets.zero,
                child: Slider(
                  value: value.current.inSeconds.toDouble(),
                  min: 0.0,
                  max: value.total.inSeconds.toDouble(),
                  onChanged: (double value) {
                    //_audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                )));
      },
    );
  }
}

class CurrentSongTitleSmall extends StatelessWidget {
  const CurrentSongTitleSmall({super.key});
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<MediaItem>(
      valueListenable: pageManager.currentMediaItemNotifier,
      builder: (_, mediaItem, __) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            mediaItem.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }
}
