import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:uni_links/uni_links.dart';

import '/language_constants.dart';
import '/screens/explore_screen.dart';
import '/screens/forme_screen.dart';
import '/screens/profile_settings_screen.dart';
import '/utils/colors.dart';
import '../helper/scrollcontroller_helper.dart';
import '../models/user_model.dart';
import '../notifiers/play_button_notifier.dart';
import '../notifiers/progress_notifier.dart';
import '../page_manager.dart';
import '../services/service_locator.dart';
import '../utils/global_functions.dart';
import 'music_player_screen.dart';

PanelController panelController = PanelController();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<String> playlist = [];
  MediaItem? item;
  final ScrollControllerHelper _scrollControllerHelper = ScrollControllerHelper();
  //PanelController _panelController = PanelController();
  ValueNotifier<bool> bottomSheetVisible = ValueNotifier<bool>(true);
  bool gestureCheck = false;
  bool panelVisibility = false;
  late List<GlobalKey<NavigatorState>> _navigatorKeys;

  void onItemTapped(int index) {
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
    onItemTapped(1);
    setState(() {});
  }

  void showPanel(bool dontShowPanel) {
    debugPrint("panel function parameter $dontShowPanel");
    if (panelController.isAttached) {
      panelVisibility = true;
      if (!dontShowPanel) {
        panelController.open();
      }
    } else {
      panelVisibility = true;
      Future.delayed(Duration(seconds: 2), () {
        if (panelController.isAttached) if (!dontShowPanel) {
          panelController.open();
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
    UserModel user = await getUser();
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
    UserModel user = await getUser();
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
      panelVisibility = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
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
        child: Scaffold(
          body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    gradientColorOne,
                    gradientColorTwo,
                  ],
                  stops: [0.0926, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  Offstage(
                    offstage: _selectedIndex != 0,
                    child: Navigator(
                      key: _navigatorKeys[0],
                      onGenerateRoute: (routeSettings) => MaterialPageRoute(
                          builder: (_) => ForMeScreen(
                              showPanel, _scrollControllerHelper, openExploreTab)),
                    ),
                  ),
                  Offstage(
                    offstage: _selectedIndex != 1,
                    child: Navigator(
                      key: _navigatorKeys[1],
                      onGenerateRoute: (routeSettings) =>
                          MaterialPageRoute(builder: (_) => ExploreScreen(showPanel)),
                    ),
                  ),
                  Offstage(
                    offstage: _selectedIndex != 2,
                    child: Navigator(
                      key: _navigatorKeys[2],
                      onGenerateRoute: (routeSettings) => MaterialPageRoute(
                          builder: (_) => ProfileSettingsScreen(showPanel)),
                    ),
                  ),
                  Visibility(
                      visible: panelVisibility,
                      maintainState: true,
                      child: Listener(
                        onPointerMove: (PointerMoveEvent event) {
                          if (event.delta.dy > 3) {
                            if (panelController.isAttached) {
                              if (panelController.isPanelClosed && panelVisibility) {
                                _hidePanel();
                              }
                            }
                          }
                        },
                        child: SlidingUpPanel(
                          maxHeight: MediaQuery.of(context).size.height,
                          minHeight: defaultTargetPlatform == TargetPlatform.android
                              ? (kBottomNavigationBarHeight + 78.h)
                              : MediaQuery.of(context).padding.bottom +
                                  kBottomNavigationBarHeight +
                                  78.h,
                          controller: panelController,
                          panel: Stack(
                            children: [
                              MusicPlayerScreen(
                                playList: playlist.length > 1 ? true : false,
                                panelControllerNest: panelController,
                              ),
                              if (panelController.isAttached)
                                ValueListenableBuilder<bool>(
                                    valueListenable: bottomSheetVisible,
                                    builder: (BuildContext context, bool value,
                                        Widget? child) {
                                      return AnimatedOpacity(
                                        opacity: value ? 1.0 : 0.0,
                                        duration: Duration(milliseconds: 100),
                                        child: Container(
                                            height: 78.h,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  gradientColorOne,
                                                  gradientColorTwo,
                                                ],
                                                stops: [0.0926, 1.0],
                                              ),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                topRight: Radius.circular(16),
                                              ),
                                            ),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      panelController.open();
                                                    },
                                                    child: Row(
                                                      children: [
                                                        ValueListenableBuilder(
                                                          valueListenable: getIt<
                                                                  PageManager>()
                                                              .currentMediaItemNotifier,
                                                          builder: (BuildContext context,
                                                              MediaItem mediaItem,
                                                              Widget? child) {
                                                            return Container(
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.only(
                                                                        topLeft: Radius
                                                                            .circular(
                                                                                16)),
                                                                child: CachedNetworkImage(
                                                                  imageUrl: mediaItem
                                                                      .artUri
                                                                      .toString(),
                                                                  width: 72.w,
                                                                  height: 72.h,
                                                                  fit: BoxFit.cover,
                                                                  errorWidget: (context,
                                                                          url, error) =>
                                                                      ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius
                                                                                  .circular(
                                                                                      20), // Adjust the radius as needed
                                                                          child:
                                                                              Image.asset(
                                                                            "images/placeholder_image.jpg",
                                                                            fit: BoxFit
                                                                                .cover,
                                                                          )),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        SizedBox(
                                                          width: 5.w,
                                                        ),
                                                        Expanded(
                                                            child:
                                                                CurrentSongTitleSmall()),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.end,
                                                          mainAxisSize: MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.center,
                                                          children: [
                                                            SizedBox(
                                                              width: 10.w,
                                                            ),
                                                            ValueListenableBuilder(
                                                              valueListenable:
                                                                  getIt<PageManager>()
                                                                      .progressNotifier,
                                                              builder:
                                                                  (BuildContext context,
                                                                      ProgressBarState
                                                                          progress,
                                                                      Widget? child) {
                                                                return Container(
                                                                    child: Text(
                                                                  "${progress.current.inMinutes.remainder(60).toString().padLeft(2, '0')}:${progress.current.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                                                                  style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontSize: 14.sp),
                                                                ));
                                                              },
                                                            ),
                                                            PlayButtonNew(),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (item?.extras?["categories"] !=
                                                      "Soundscape")
                                                    AudioProgressBarHome()
                                                ])),
                                      );
                                    })
                            ],
                          ),
                          onPanelSlide: (double pos) {
                            if (pos > 0.08) {
                              bottomSheetVisible.value = false;
                            } else {
                              bottomSheetVisible.value = true;
                            }
                          },
                          color: Colors.transparent,
                        ),
                      )),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ValueListenableBuilder<bool>(
                          valueListenable: bottomSheetVisible,
                          builder: (BuildContext context, bool value, Widget? child) {
                            return AnimatedOpacity(
                                opacity: value ? 1.0 : 0.0,
                                duration: Duration(milliseconds: 300),
                                child: Container(
                                  height: defaultTargetPlatform == TargetPlatform.android
                                      ? kBottomNavigationBarHeight + 2.h
                                      : (MediaQuery.of(context).padding.bottom +
                                          kBottomNavigationBarHeight +
                                          2.h),
                                  color: lightBlueColor,
                                  //padding: EdgeInsets.only(top: 2.h,bottom: defaultTargetPlatform == TargetPlatform.android ? 2.h : 0.0,),
                                  child: BottomNavigationBar(
                                    elevation: 0.0,
                                    //iconSize: 26.h,
                                    items: <BottomNavigationBarItem>[
                                      BottomNavigationBarItem(
                                        icon: _selectedIndex == 0
                                            ? const Icon(
                                                CupertinoIcons.house_fill,
                                              )
                                            : const Icon(
                                                CupertinoIcons.house,
                                              ),
                                        label: translation(context).home,
                                      ),
                                      BottomNavigationBarItem(
                                        icon: _selectedIndex == 1
                                            ? SvgPicture.asset(
                                                "assets/search_icon_filled.svg",
                                              )
                                            : SvgPicture.asset(
                                                "assets/search_icon.svg",
                                              ),
                                        label: translation(context).explore,
                                      ),
                                      BottomNavigationBarItem(
                                        icon: _selectedIndex == 2
                                            ? SvgPicture.asset(
                                                "assets/user_icon_filled.svg",
                                              )
                                            : SvgPicture.asset(
                                                "assets/user_icon.svg",
                                              ),
                                        label: translation(context).profile,
                                      ),
                                    ],
                                    currentIndex: _selectedIndex,
                                    selectedItemColor: Colors.white,
                                    unselectedItemColor: Colors.white,
                                    backgroundColor: lightBlueColor,
                                    onTap: onItemTapped,
                                  ),
                                ));
                          }))
                ],
              )),
        ));
  }

  void initDeepLinking() async {
    // Platform messages are asynchronous, so we initialize in an async method.
    try {
      // Request permission to handle incoming links
      getUriLinksStream().listen((Uri? uri) {
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
              margin: EdgeInsets.all(8.w),
              height: 24.h,
              width: 24.w,
              child: const CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          case ButtonState.paused:
            return IconButton(
              icon: const Icon(Icons.play_arrow),
              iconSize: 24.h,
              onPressed: pageManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: const Icon(Icons.pause),
              iconSize: 24.h,
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
              fontSize: 16.sp,
            ),
          ),
        );
      },
    );
  }
}
