import 'package:app_links/app_links.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '/helper/scrollcontroller_helper.dart';
import '/screens/explore_screen.dart';
import '/screens/forme_screen.dart';
import '/screens/profile_settings_screen.dart';
import '/utils/colors.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '../../domain/blocs/user/app_user.dart';
import '../../domain/services/service_locator.dart';
import '../../notifiers/play_button_notifier.dart';
import '../../notifiers/progress_notifier.dart';
import '../../page_manager.dart';
import '../../utils/global_functions.dart';
import '../music_player_screen.dart';
import 'app_bottom_bar.dart';
import 'music_panel_preview.dart';

PanelController panelController = PanelController();

class HomeScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final List<Widget> _navigationScreens = [
    ForMeScreen(showPanel, _scrollControllerHelper, openExploreTab),
    ExploreScreen(showPanel),
    ProfileSettingsScreen(showPanel),
  ];

  late final _bottomSheetAnimationController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  int _selectedIndex = 0;
  List<String> playlist = [];
  MediaItem? item;
  final ScrollControllerHelper _scrollControllerHelper = ScrollControllerHelper();
  //PanelController _panelController = PanelController();
  ValueNotifier<bool> bottomSheetVisible = ValueNotifier<bool>(true);
  bool gestureCheck = false;
  double panelVisibility = 0;
  late List<GlobalKey<NavigatorState>> _navigatorKeys;

  final _panelKey = GlobalKey();

  void _selectScreen(int index) {
    // TODO: INVERSTIGATE THIS THINGAMAJIGGERY
    final NavigatorState currentNavigator = _navigatorKeys[_selectedIndex].currentState!;
    if (currentNavigator.canPop()) {
      currentNavigator.pop();
      if (currentNavigator.canPop()) {
        currentNavigator.pop();
      }
    }
    setState(() {
      if (_selectedIndex == index) {
        _scrollControllerHelper.scrollToTop();
      }
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    _navigatorKeys = List.generate(3, (_) => GlobalKey<NavigatorState>());
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
        body: Stack(
          children: [
            for (int i = 0; i < _navigationScreens.length; i++) _buildNavigationScreen(i),
            _buildSlidingPanel(height, bottom),
          ],
        ),
        bottomNavigationBar: AnimatedBuilder(
          animation: _bottomSheetAnimationController,
          builder: (context, child) => Transform.translate(
            offset: Offset(
              0,
              _bottomSheetAnimationController.value * (AppBottomBar.height + bottom),
            ),
            child: child,
          ),
          child: AppBottomBar(onSelect: _selectScreen),
        ),
      ),
    );
  }

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
              _bottomSheetAnimationController.value = pos;
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
                    animation: _bottomSheetAnimationController,
                    builder: (context, child) => Opacity(
                      opacity: 1 -
                          CurvedAnimation(
                                  parent: _bottomSheetAnimationController,
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

  Widget _buildNavigationScreen(int index) => Offstage(
        offstage: _selectedIndex != index,
        child: Navigator(
          key: _navigatorKeys[index],
          onGenerateRoute: (routeSettings) => MaterialPageRoute(
            builder: (context) => _navigationScreens[index],
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
