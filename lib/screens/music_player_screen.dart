import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sleeptales/constants/assets.dart';
import 'package:sleeptales/domain/services/audio_panel_manager.dart';
import 'package:sleeptales/utils/app_theme.dart';
import 'package:sleeptales/utils/get.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '/screens/timer_picker_screen.dart';
import '/utils/global_functions.dart';
import '/widgets/circle_icon_button.dart';
import '../domain/blocs/user/app_user.dart';
import '../domain/services/service_locator.dart';
import '../notifiers/play_button_notifier.dart';
import '../notifiers/progress_notifier.dart';
import '../notifiers/repeat_notifier.dart';
import '../page_manager.dart';
import '../utils/colors.dart';

class MusicPlayerScreen extends StatefulWidget {
  final bool isPlaylist;
  final PanelController? panelControllerNest;
  const MusicPlayerScreen(
      {super.key, required this.isPlaylist, this.panelControllerNest});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final _audioPanelManager = Get.the<AudioPanelManager>();

  final _audioHandler = getIt<AudioHandler>();
  AppUser? user;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool favorite = false;
  bool timerOn = false;
  int timerValue = 2;
  bool hide = false;
  bool favoriteLoading = false;
  List<String> favList = [];
  final pageManagerNew = getIt<PageManager>();

  @override
  void initState() {
    super.initState();

    getUserFromPref();
    getFavArray();
  }

  Future<void> addTrackToFavorites(String userId, String trackId) async {
    setState(() {
      favoriteLoading = true;
    });
    final favoritesCollection = FirebaseFirestore.instance.collection('favorites');
    final userFavoritesDocRef = favoritesCollection.doc(userId);

    final favoritesDocSnapshot = await userFavoritesDocRef.get();
    if (favoritesDocSnapshot.exists) {
      final favoritesData = favoritesDocSnapshot.data();
      List<String> favorites = List.from(favoritesData!['favorites']);
      if (!favorites.contains(trackId)) {
        favorites.add(trackId);
        await userFavoritesDocRef.update({'favorites': favorites});
      }
    } else {
      await userFavoritesDocRef.set({
        'favorites': [trackId]
      });
    }
    setState(() {
      favorite = true;
      favoriteLoading = false;
      favList.add(trackId);
      addFavoriteListToSharedPref(favList);
      showToast("Track added to favorites");
    });
  }

  Future<void> getFavArray() async {
    favList = await getFavoriteListFromSharedPref();
    setState(() {});
  }

  Future<void> removeFavorite(String userId, String trackId) async {
    setState(() {
      favoriteLoading = true;
    });
    try {
      final favoritesRef = FirebaseFirestore.instance.collection('favorites').doc(userId);

      await favoritesRef.update({
        'favorites': FieldValue.arrayRemove([trackId])
      });

      setState(() {
        favorite = false;
        favoriteLoading = false;
        favList.remove(trackId);
        removeFromFavoritesList(trackId);
      });
      showToast('Track removed from favorites');
    } catch (e) {
      showToast('Error removing track from favorites: $e');
      setState(() {
        favoriteLoading = false;
      });
    }
  }

  //}

  void toggleHide() {
    setState(() {
      hide = !hide;
    });
  }

  void toggleTimer() {
    setState(() {
      timerOn = !timerOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: AppTheme.smallBorderRadius.topLeft,
                topRight: AppTheme.smallBorderRadius.topRight,
              ),
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
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: GestureDetector(
                  onTap: () => toggleHide(),
                  child: ValueListenableBuilder(
                    valueListenable: getIt<PageManager>().currentMediaItemNotifier,
                    builder: (BuildContext context, MediaItem mediaItem, Widget? child) {
                      if (mediaItem.id != "") {
                        if (favList.contains(mediaItem.id)) {
                          favorite = true;
                        } else {
                          favorite = false;
                        }
                      }
                      return mediaItem.id.isNotEmpty
                          ? Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: AppTheme.smallBorderRadius.topLeft,
                                        topRight: AppTheme.smallBorderRadius.topRight,
                                      ),
                                      child: (mediaItem.artUri != null &&
                                              mediaItem.artUri.toString() != "")
                                          ? CachedNetworkImage(
                                              imageUrl: mediaItem.artUri.toString(),
                                              fit: BoxFit.cover,
                                              height: double.infinity,
                                              width: double.infinity,
                                              fadeInDuration: Duration(milliseconds: 100),
                                              errorWidget: (context, url, error) =>
                                                  Image.asset(
                                                    Assets.placeholderImage,
                                                    fit: BoxFit.cover,
                                                  ))
                                          : Icon(
                                              Icons.music_note,
                                              color: blueAccentColor,
                                            )),
                                ),
                                if (!hide)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 16, top: 50),
                                        child: CircleIconButton(
                                          icon: Icons.arrow_back_ios_new,
                                          onPressed: () {
                                            //widget.onPopUpClosed();
                                            //Navigator.of(context).pop();

                                            if (_audioPanelManager
                                                .panelController.isAttached) {
                                              _audioPanelManager.panelController.close();
                                            }
                                          },
                                          backgroundColor: transparentWhite,
                                          size: 40,
                                          iconSize: 24,
                                        ),
                                      ),
                                      SizedBox(height: 68),
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(5),
                                          child: CurrentSongTitle(),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            mediaItem.displayDescription ?? "",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          if (!hide)
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                (!favoriteLoading)
                                                    ? CircleIconButton(
                                                        icon: Icons.favorite_border,
                                                        onPressed: () {
                                                          if (favorite) {
                                                            removeFavorite(user!.id!,
                                                                mediaItem.extras!['id']);
                                                          } else {
                                                            addTrackToFavorites(user!.id!,
                                                                mediaItem.extras!['id']);
                                                          }
                                                        },
                                                        backgroundColor: favorite
                                                            ? Colors.blue
                                                            : Colors.black,
                                                        size: 48,
                                                        iconSize: 24,
                                                      )
                                                    : Container(
                                                        margin: EdgeInsets.all(8),
                                                        height: 30,
                                                        width: 30,
                                                        child:
                                                            const CircularProgressIndicator(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                SizedBox(
                                                  width: 24,
                                                ),
                                                CircleIconButton(
                                                  icon: Icons.share,
                                                  onPressed: () {
                                                    createDeepLink(mediaItem.id);
                                                  },
                                                  backgroundColor: Colors.black,
                                                  size: 48,
                                                  iconSize: 24,
                                                ),
                                                if (mediaItem.extras?["categories"] !=
                                                        "Sleep Story" &&
                                                    mediaItem.extras?["categories"] !=
                                                        "Meditation") ...[
                                                  SizedBox(
                                                    width: 24,
                                                  ),
                                                  CircleIconButton(
                                                    icon: Icons.timer_outlined,
                                                    onPressed: () {
                                                      setState(() {
                                                        toggleTimer();
                                                        pushName(
                                                            context, SleepTimerScreen());
                                                      });
                                                    },
                                                    backgroundColor: Colors.black,
                                                    size: 48,
                                                    iconSize: 24,
                                                  ),
                                                ]
                                              ],
                                            ),
                                          SizedBox(height: 40),
                                          if (!hide)
                                            StreamBuilder<bool>(
                                              stream: _audioHandler.playbackState
                                                  .map((state) => state.playing)
                                                  .distinct(),
                                              builder: (context, snapshot) {
                                                final playing = snapshot.data ?? false;
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    if (mediaItem.extras?["categories"] ==
                                                            "Sleep Story" ||
                                                        mediaItem.extras?["categories"] ==
                                                            "Soundscape") ...[
                                                      SizedBox(
                                                        width: 32,
                                                        height: 32,
                                                      )
                                                    ] else if (mediaItem
                                                                .extras?["categories"] ==
                                                            "Music" &&
                                                        widget.isPlaylist) ...[
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.shuffle,
                                                          color: getIt<PageManager>()
                                                                  .isShuffleModeEnabledNotifier
                                                                  .value
                                                              ? Colors.green
                                                              : Colors.white,
                                                          size: 32,
                                                        ),
                                                        onPressed: () {
                                                          final pageManager =
                                                              getIt<PageManager>();
                                                          pageManager.shuffle();
                                                          setState(() {});
                                                        },
                                                      ),
                                                    ] else if (mediaItem
                                                                .extras?["categories"] ==
                                                            "Music" &&
                                                        widget.isPlaylist == false) ...[
                                                      SizedBox(
                                                        height: 32,
                                                        width: 32,
                                                      ),
                                                    ] else ...[
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.tune,
                                                          color: Colors.white,
                                                          size: 32,
                                                        ),
                                                        onPressed: () {},
                                                      ),
                                                    ],
                                                    if (widget.isPlaylist) ...[
                                                      if (pageManagerNew
                                                          .isFirstSongNotifier.value) ...{
                                                        if (pageManagerNew
                                                                .repeatButtonNotifier
                                                                .value ==
                                                            RepeatState.off) ...{
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.skip_previous,
                                                              color: Colors.grey,
                                                              size: 32,
                                                            ),
                                                            onPressed: () {
                                                              // final pageManager = getIt<PageManager>();
                                                              // pageManager.previous();
                                                            },
                                                          ),
                                                        } else ...{
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.skip_previous,
                                                              color: Colors.white,
                                                              size: 32,
                                                            ),
                                                            onPressed: () {
                                                              // final pageManager = getIt<PageManager>();
                                                              pageManagerNew.previous();
                                                            },
                                                          ),
                                                        }
                                                      } else ...{
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.skip_previous,
                                                            color: Colors.white,
                                                            size: 32,
                                                          ),
                                                          onPressed: () {
                                                            // final pageManager = getIt<PageManager>();
                                                            pageManagerNew.previous();
                                                          },
                                                        ),
                                                      }
                                                    ] else ...[
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.replay_10,
                                                          color: Colors.white,
                                                          size: 32,
                                                        ),
                                                        onPressed: () {
                                                          final pageManager =
                                                              getIt<PageManager>();
                                                          pageManager.skipBackward();
                                                        },
                                                      ),
                                                    ],
                                                    PlayButton(),
                                                    if (widget.isPlaylist) ...[
                                                      if (pageManagerNew
                                                          .isLastSongNotifier.value) ...{
                                                        if (!(pageManagerNew
                                                                .isShuffleModeEnabledNotifier
                                                                .value) &&
                                                            pageManagerNew
                                                                    .repeatButtonNotifier
                                                                    .value ==
                                                                RepeatState.off) ...{
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.skip_next,
                                                              color: Colors.grey,
                                                              size: 32,
                                                            ),
                                                            onPressed: () {},
                                                          ),
                                                        } else ...{
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.skip_next,
                                                              color: Colors.white,
                                                              size: 32,
                                                            ),
                                                            onPressed: () {
                                                              pageManagerNew.next();
                                                            },
                                                          ),
                                                        }
                                                      } else ...{
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.skip_next,
                                                            color: Colors.white,
                                                            size: 32,
                                                          ),
                                                          onPressed: () {
                                                            pageManagerNew.next();
                                                          },
                                                        ),
                                                      }
                                                    ] else ...[
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.forward_10_outlined,
                                                          color: Colors.white,
                                                          size: 32,
                                                        ),
                                                        onPressed: () {
                                                          final pageManager =
                                                              getIt<PageManager>();
                                                          pageManager.skipForward();
                                                        },
                                                      ),
                                                    ],
                                                    if (widget.isPlaylist) ...[
                                                      IconButton(
                                                        icon: Icon(
                                                          getIt<PageManager>()
                                                                      .repeatButtonNotifier
                                                                      .value ==
                                                                  RepeatState.repeatSong
                                                              ? Icons.repeat_one
                                                              : Icons.repeat,
                                                          color: getIt<PageManager>()
                                                                      .repeatButtonNotifier
                                                                      .value ==
                                                                  RepeatState.off
                                                              ? Colors.white
                                                              : Colors.green,
                                                          size: 32,
                                                        ),
                                                        onPressed: () {
                                                          final pageManager =
                                                              getIt<PageManager>();
                                                          pageManager.repeat();
                                                          setState(() {});
                                                        },
                                                      ),
                                                    ] else if (mediaItem
                                                            .extras?["categories"] ==
                                                        "Soundscape") ...[
                                                      SizedBox(
                                                        width: 32,
                                                        height: 32,
                                                      )
                                                    ] else ...[
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.square,
                                                          color: Colors.white,
                                                          size: 32,
                                                        ),
                                                        onPressed: () {
                                                          final pageManager =
                                                              getIt<PageManager>();
                                                          pageManager.stop();
                                                        },
                                                      ),
                                                    ]
                                                  ],
                                                );
                                              },
                                            ),
                                          SizedBox(height: 32),
                                          if (mediaItem.extras?["categories"] !=
                                              "Soundscape")
                                            AudioProgressBar(),
                                          SizedBox(height: 30),
                                        ],
                                      ),
                                    ))
                              ],
                            )
                          : Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                    },
                  ),
                ))),
        onWillPop: () async {
          //widget.onPopUpClosed();
          return true;
        });
  }

  // void startTimer() {
  //   // start timer for 5 minutes
  //   _timer = Timer(Duration(seconds: 20), () {
  //     // stop playing music after 5 minutes
  //     pauseMusic();
  //   });
  //
  //   toggleTimer();
  //
  // }

  void getUserFromPref() async {
    user = await getUser();
  }

  void createDeepLink(String trackId) {
    String customScheme = 'com.sleeptales.sleeptales'; // Replace with your custom scheme

    String deepLinkUrl = '$customScheme://track?id=$trackId';

    String sharedMessage = 'Check out this track: $deepLinkUrl';

    // Prepend the custom scheme with the http:// protocol
    String url = 'http://$deepLinkUrl';

    Share.share(
      sharedMessage,
      subject: 'Track',
      sharePositionOrigin: Rect.fromLTWH(0, 0, 10, 10),
    );
  }

  Future<void> isTrackFavorite(String userId, String trackId) async {
    setState(() {
      favoriteLoading = true;
    });
    final favoritesCollection = FirebaseFirestore.instance.collection('favorites');
    final userFavoritesDocRef = favoritesCollection.doc(userId);

    final favoritesDocSnapshot = await userFavoritesDocRef.get();
    if (favoritesDocSnapshot.exists) {
      final favoritesData = favoritesDocSnapshot.data();
      List<String> favorites = List.from(favoritesData!['favorites']);

      setState(() {
        favorite = favorites.contains(trackId);
        favoriteLoading = false;
        showToast(favoriteLoading.toString());
      });
    } else {
      setState(() {
        favoriteLoading = false;
        favorite = false;
        showToast(favoriteLoading.toString());
      });
    }
  }
}

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({super.key});
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: pageManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: pageManager.seek,
          baseBarColor: Colors.white.withAlpha(70),
          progressBarColor: Colors.white,
          thumbColor: Colors.white,
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({super.key});
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
              height: 45,
              width: 45,
              child: const CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          case ButtonState.paused:
            return
                //   IconButton(
                //   icon: const Icon(Icons.play_arrow),
                //   iconSize: 32.0,
                //   onPressed: pageManager.play,
                // );
                CircleIconButton(
                    icon: Icons.play_arrow,
                    onPressed: pageManager.play,
                    backgroundColor: transparentWhite,
                    size: 64,
                    iconSize: 40);
          case ButtonState.playing:
            return
                //   CircleIconButton(
                //   icon: const Icon(Icons.pause),
                //   iconSize: 32.0,
                //   onPressed: pageManager.pause,
                // );
                CircleIconButton(
                    icon: Icons.pause,
                    onPressed: pageManager.pause,
                    backgroundColor: transparentWhite,
                    size: 64,
                    iconSize: 40);
        }
      },
    );
  }
}

class CurrentSongTitle extends StatelessWidget {
  const CurrentSongTitle({super.key});
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<String>(
      valueListenable: pageManager.currentSongTitleNotifier,
      builder: (_, title, __) {
        return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ));
      },
    );
  }
}
