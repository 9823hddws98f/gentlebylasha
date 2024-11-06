import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/constants/assets.dart';
import '/domain/blocs/user/app_user.dart';
import '/domain/models/block_item/audio_playlist.dart';
import '/domain/services/audio_panel_manager.dart';
import '/domain/services/service_locator.dart';
import '/page_manager.dart';
import '/utils/colors.dart';
import '/utils/get.dart';
import '/utils/global_functions.dart';
import '/widgets/app_image.dart';

class PlayListScreen extends StatefulWidget {
  final AudioPlaylist playlist;

  const PlayListScreen({
    super.key,
    required this.playlist,
  });

  @override
  State<PlayListScreen> createState() => _PlayListScreenState();
}

class _PlayListScreenState extends State<PlayListScreen> {
  final _audioPanelManager = Get.the<AudioPanelManager>();

  AppUser? user;
  bool favoritePlayListLoading = false;
  List<String> favoritesList = [];
  List<String> favoritesPlayList = [];
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarExpanded = true;
  bool favoriteSeries = false;
  List<String> currentPlayingList = [];
  bool currentPlaylistIsPlaying = false;
  bool playing = false;
  MediaItem currentMediaItem = MediaItem(id: "", title: "");

  bool isTrackFavorited(String trackId) {
    return favoritesList.contains(trackId);
  }

  bool isPlaylistFavorited(String trackId) {
    return favoritesPlayList.contains(trackId);
  }

  @override
  void initState() {
    super.initState();
    getUserFromPref();
    getFavArray();
    getFavPlayListArray();
    _scrollController.addListener(() {
      setState(() {
        _isAppBarExpanded = _scrollController.hasClients &&
            _scrollController.offset < (250.0 - kToolbarHeight);
      });
    });
    _onPlaylistChanged();
    currentPlayingMediaItem();
    getIt<PageManager>().playlistNotifier.addListener(_onPlaylistChanged);
    getIt<PageManager>().currentMediaItemNotifier.addListener(currentPlayingMediaItem);
  }

  void currentPlayingMediaItem() {
    setState(() {
      if (mounted) {
        currentMediaItem = getIt<PageManager>().currentMediaItemNotifier.value;
      }
    });
  }

  void _onPlaylistChanged() {
    setState(() {
      if (mounted) {
        currentPlayingList = getIt<PageManager>().playlistIdNotifier.value;
      }
      currentPlaylistIsPlaying = currentPlayingList.every(
        (id) => widget.playlist.trackIds.any((trackId) => trackId == id),
      );
    });
  }

  Future<void> addPlaylistToFavorites(String playListId) async {
    setState(() {
      favoritePlayListLoading = true;
    });
    final favoritesCollection =
        FirebaseFirestore.instance.collection('favorites_playlist');
    final userFavoritesDocRef = favoritesCollection.doc(user!.id);
    final favoritesDocSnapshot = await userFavoritesDocRef.get();
    if (favoritesDocSnapshot.exists) {
      final favoritesData = favoritesDocSnapshot.data();
      if (favoritesData!['playlist'] != null) {
        List<String> favoritesDataPlayList = List.from(favoritesData['playlist']);
        if (!favoritesDataPlayList.contains(playListId)) {
          favoritesDataPlayList.add(playListId);
          await userFavoritesDocRef.update({'playlist': favoritesDataPlayList});
        }
      } else {
        await userFavoritesDocRef.set({
          'playlist': [playListId]
        });
      }
    } else {
      await userFavoritesDocRef.set({
        'playlist': [playListId]
      });
    }
    setState(() {
      favoritesPlayList.add(playListId);
      addFavoritePlayListToSharedPref(favoritesPlayList);
      favoritePlayListLoading = false;
      showToast("Playlist added to favorites");
    });
  }

  Future<void> removePlayListFavorites(String blockId) async {
    setState(() {
      favoritePlayListLoading = true;
    });

    try {
      final favoritesRef =
          FirebaseFirestore.instance.collection('favorites_playlist').doc(user!.id);
      await favoritesRef.update({
        'playlist': FieldValue.arrayRemove([blockId])
      });

      setState(() {
        favoritesPlayList.remove(blockId);
        removeFromFavoritesPlayList(blockId);
        favoritePlayListLoading = false;
      });
      showToast('Playlist removed from favorites');
    } catch (e) {
      showToast('Error removing track from favorites: $e');
      setState(() {
        favoritePlayListLoading = false;
      });
    }
  }

  Future<void> addTrackToFavorites(String trackId) async {
    final favoritesCollection = FirebaseFirestore.instance.collection('favorites');
    final userFavoritesDocRef = favoritesCollection.doc(user!.id);

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
      favoritesList.add(trackId);
      addFavoriteListToSharedPref(favoritesList);
      showToast("Track added to favorites");
    });
  }

  Future<void> removeFavorite(String trackId) async {
    try {
      final favoritesRef =
          FirebaseFirestore.instance.collection('favorites').doc(user!.id);

      await favoritesRef.update({
        'favorites': FieldValue.arrayRemove([trackId])
      });

      setState(() {
        favoritesList.remove(trackId);
        removeFromFavoritesList(trackId);
      });
      showToast('Track removed from favorites');
    } catch (e) {
      showToast('Error removing track from favorites: $e');
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
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
      child: CustomScrollView(
        controller: _scrollController,
        physics:
            _isAppBarExpanded ? AlwaysScrollableScrollPhysics() : ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 266.0,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios), // Change this icon as needed
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: _isAppBarExpanded ? null : Text(widget.playlist.title),
              background: AppImage(
                imageUrl: widget.playlist.thumbnail,
                fit: BoxFit.cover,
                placeholderAsset: Assets.placeholderImage,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 8, 16),
                child: _isAppBarExpanded
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Text(
                            widget.playlist.title,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                          )),
                          Stack(
                            children: [
                              favoritePlayListLoading
                                  ? Padding(
                                      padding: EdgeInsets.all(8),
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: Center(
                                            child: CircularProgressIndicator(
                                          color: Colors.white,
                                        )),
                                      ),
                                    )
                                  : IconButton(
                                      onPressed: () {
                                        if (isPlaylistFavorited(widget.playlist.id)) {
                                          removePlayListFavorites(widget.playlist.id);
                                        } else {
                                          addPlaylistToFavorites(widget.playlist.id);
                                        }
                                      },
                                      icon: isPlaylistFavorited(widget.playlist.id)
                                          ? Icon(
                                              Icons.favorite,
                                              size: 24,
                                            )
                                          : Icon(
                                              Icons.favorite_border,
                                              size: 24,
                                            ),
                                      constraints: BoxConstraints(),
                                    )
                            ],
                          )
                        ],
                      )
                    : null,
              ),
              Container(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: widget.playlist.authorImage.isNotEmpty
                          ? AppImage(
                              imageUrl: widget.playlist.authorImage,
                              borderRadius: BorderRadius.circular(64),
                              placeholderAsset: Assets.profile,
                              errorWidget: (context, url, error) => Image.asset(
                                Assets.profile,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              Assets.profile,
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: Text(
                            widget.playlist.author,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: Text(
                            widget.playlist.profession,
                            style: TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // TODO: UNCOMMENT
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 16),
              //   child: CustomButton(
              //       title: (currentPlaylistIsPlaying && playing) ? "Pause" : "Play",
              //       onPress: () {
              //         if (currentPlaylistIsPlaying && playing) {
              //           getIt<PageManager>().pause();
              //           showPanel(true);
              //         } else if (currentPlaylistIsPlaying && !playing) {
              //           getIt<PageManager>().loadPlaylist(widget.list, 0);
              //           getIt<PageManager>().play();
              //           showPanel(true);
              //         } else {
              //           getIt<PageManager>().loadPlaylist(widget.list, 0);
              //           getIt<PageManager>().play();
              //           showPanel(false);
              //         }
              //       },
              //       color: Colors.white,
              //       textColor: textColor),
              // ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.playlist.description,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 32, left: 16, right: 16),
                child: Divider(
                  height: 1.0,
                  color: seriesDividerColor,
                ),
              ),
              // TODO: UNCOMMENT
              // ListView.separated(
              //   physics: NeverScrollableScrollPhysics(),
              //   shrinkWrap: true,
              //   padding: EdgeInsets.only(left: 16, right: 16, bottom: 200),
              //   itemCount: widget.list.length,
              //   itemBuilder: (BuildContext context, int index) {
              //     return Padding(
              //       padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
              //       child: SeriesTrackListImageWidget(
              //         // TODO: THIS SHOULD BE TOGGALBLE IMAGE
              //         audioTrack: widget.list[index],
              //         tap: () {
              //           getIt<PageManager>().loadPlaylist(widget.list, index);
              //           showPanel(false);
              //         },
              //         favoriteTap: () async {
              //           if (isTrackFavorited(widget.list[index].trackId)) {
              //             removeFavorite(widget.list[index].trackId);
              //           } else {
              //             addTrackToFavorites(widget.list[index].trackId);
              //           }
              //           setState(() {});
              //         },
              //         favorite: isTrackFavorited(widget.list[index].trackId),
              //       ),
              //     );
              //   },
              //   separatorBuilder: (BuildContext context, int index) {
              //     return Divider(
              //       height: 1.0,
              //       color: seriesDividerColor,
              //     );
              //   },
              // ),
              Padding(
                padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Divider(
                  height: 1.0,
                  color: seriesDividerColor,
                ),
              ),
            ]),
          ),
        ],
      ),
    ));
  }

  void showPanel(bool value) => _audioPanelManager.maximize(value);

  Future<void> getFavArray() async {
    favoritesList = await getFavoriteListFromSharedPref();
    setState(() {});
  }

  Future<void> getFavPlayListArray() async {
    favoritesPlayList = await getFavoritePlayListFromSharedPref();
    setState(() {});
  }

  void getUserFromPref() async {
    user = await getUser();
  }
}
