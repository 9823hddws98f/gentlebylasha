import 'package:flutter/material.dart';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/audiofile_model.dart';
import '../models/block.dart';
import '../models/user_model.dart';
import '../notifiers/play_button_notifier.dart';
import '../page_manager.dart';
import '../services/service_locator.dart';
import '../utils/firestore_helper.dart';
import '../utils/global_functions.dart';
import '../widgets/series_track_widget.dart';
import '../widgets/shimmerwidgets/shimmer_series_track_widget.dart';
import '/utils/colors.dart';
import '/widgets/custom_btn.dart';
import '/widgets/series_track_image_widget.dart';
import '/widgets/shimmerwidgets/shimmer_series_track_image_widget.dart';

class PlayListTracksScreen extends StatefulWidget {
  final Block block;
  final Function panelFunction;

  const PlayListTracksScreen(
      {super.key, required this.panelFunction, required this.block});

  @override
  _TrackListScreenState createState() => _TrackListScreenState();
}

class _TrackListScreenState extends State<PlayListTracksScreen> {
  UserModel? user;
  bool favoritePlayListLoading = false;
  List<String> favoritesList = [];
  List<String> favoritesPlayList = [];
  List<AudioTrack> tracksList = [];
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarExpanded = true;
  bool favoriteSeries = false;
  bool trackListLoading = false;
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
    fetchAndSetTracks(widget.block.id);
    _scrollController.addListener(() {
      setState(() {
        _isAppBarExpanded = _scrollController.hasClients &&
            _scrollController.offset < (250.0 - kToolbarHeight);
      });
    });

    _onPlaylistChanged();
    _onPlayingButtonStateChnaged();
    currentPlayingMediaItem();
    getIt<PageManager>().playlistNotifier.addListener(_onPlaylistChanged);
    getIt<PageManager>().playButtonNotifier.addListener(_onPlayingButtonStateChnaged);
    getIt<PageManager>().currentMediaItemNotifier.addListener(currentPlayingMediaItem);
  }

  void currentPlayingMediaItem() {
    setState(() {
      if (mounted) {
        currentMediaItem = getIt<PageManager>().currentMediaItemNotifier.value;
      }
    });
  }

  void _onPlayingButtonStateChnaged() {
    setState(() {
      if (mounted) {
        if (getIt<PageManager>().playButtonNotifier.value == ButtonState.paused) {
          playing = false;
        } else {
          playing = true;
        }
      }
    });
  }

  void _onPlaylistChanged() {
    setState(() {
      if (mounted) {
        currentPlayingList = getIt<PageManager>().playlistIdNotifier.value;
      }
      currentPlaylistIsPlaying = currentPlayingList
          .every((id) => tracksList.any((track) => track.trackId == id));
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

  // Function to fetch tracks for a block and update the state
  Future<void> fetchAndSetTracks(String blockId) async {
    trackListLoading = true;
    final tracks = await fetchTracksForBlock(blockId);
    //debugPrint("tracks length ${tracks.length}");
    setState(() {
      tracksList = tracks;
      trackListLoading = false;
    });
    // debugPrint(tracks.length);
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
                title: _isAppBarExpanded ? null : Text(widget.block.title),
                background: CachedNetworkImage(
                  imageUrl: widget.block.thumbnail,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Image.asset(
                    "images/placeholder_image.jpg",
                    fit: BoxFit.cover,
                  ),
                )),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 10.h, 8.w, 16.h),
                child: _isAppBarExpanded
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Text(
                            widget.block.title,
                            style:
                                TextStyle(fontWeight: FontWeight.bold, fontSize: 24.sp),
                          )),
                          Stack(
                            children: [
                              favoritePlayListLoading
                                  ? Padding(
                                      padding: EdgeInsets.all(8.w),
                                      child: SizedBox(
                                        height: 20.h,
                                        width: 20.w,
                                        child: Center(
                                            child: CircularProgressIndicator(
                                          color: Colors.white,
                                        )),
                                      ),
                                    )
                                  : IconButton(
                                      onPressed: () {
                                        if (isPlaylistFavorited(widget.block.id)) {
                                          removePlayListFavorites(widget.block.id);
                                        } else {
                                          addPlaylistToFavorites(widget.block.id);
                                        }
                                      },
                                      icon: isPlaylistFavorited(widget.block.id)
                                          ? Icon(
                                              Icons.favorite,
                                              size: 24.w,
                                            )
                                          : Icon(
                                              Icons.favorite_border,
                                              size: 24.w,
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
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 40.w,
                      height: 40.h,
                      child: widget.block.authorImage != null
                          ? CachedNetworkImage(
                              imageUrl: widget.block.authorImage,
                              imageBuilder: (context, imageProvider) => CircleAvatar(
                                backgroundImage: imageProvider,
                                radius: 40.h,
                              ),
                              placeholder: (context, url) => Image.asset(
                                "images/profile.png",
                                fit: BoxFit.cover,
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                "images/profile.png",
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              "images/profile.png",
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(width: 8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 0.w),
                          child: Text(
                            widget.block.author,
                            style: TextStyle(
                              fontSize: 16.0.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 0.w),
                          child: Text(
                            widget.block.profession,
                            style: TextStyle(
                              fontSize: 14.0.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CustomButton(
                    title: (currentPlaylistIsPlaying && playing) ? "Pause" : "Play",
                    onPress: () {
                      if (currentPlaylistIsPlaying && playing) {
                        getIt<PageManager>().pause();
                        widget.panelFunction(true);
                      } else if (currentPlaylistIsPlaying && !playing) {
                        getIt<PageManager>().loadPlaylist(tracksList, 0);
                        getIt<PageManager>().play();
                        widget.panelFunction(true);
                      } else {
                        getIt<PageManager>().loadPlaylist(tracksList, 0);
                        getIt<PageManager>().play();
                        widget.panelFunction(false);
                      }
                    },
                    color: tracksList.isEmpty ? Colors.grey : Colors.white,
                    textColor: tracksList.isEmpty ? Colors.black12 : textColor),
              ),
              SizedBox(
                height: 16.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  widget.block.description,
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
              if (trackListLoading || tracksList.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 32.h, left: 16.w, right: 16.w),
                  child: Divider(
                    height: 1.0,
                    color: Colors.grey,
                  ),
                ),
              tracksList.isNotEmpty
                  ? ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 200.h),
                      itemCount: tracksList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(0, 8.h, 0, 8.h),
                          child: widget.block.showSeriesImg != "1"
                              ? SeriesTrackListWidget(
                                  audioTrack: tracksList[index],
                                  tap: () {
                                    getIt<PageManager>().loadPlaylist(tracksList, index);
                                    widget.panelFunction(false);
                                  },
                                  onTapPlayPause: () {
                                    if (currentPlaylistIsPlaying &&
                                        currentMediaItem.id ==
                                            tracksList[index].trackId &&
                                        playing) {
                                      getIt<PageManager>().pause();
                                    } else {
                                      getIt<PageManager>()
                                          .loadPlaylist(tracksList, index);
                                      getIt<PageManager>().play();
                                      widget.panelFunction(true);
                                    }
                                  },
                                  favoriteTap: () {
                                    if (isTrackFavorited(tracksList[index].trackId)) {
                                      removeFavorite(tracksList[index].trackId);
                                    } else {
                                      addTrackToFavorites(tracksList[index].trackId);
                                    }
                                    setState(() {});
                                  },
                                  favorite: isTrackFavorited(tracksList[index].trackId),
                                  currentPlaying: (currentPlaylistIsPlaying &&
                                          currentMediaItem.id ==
                                              tracksList[index].trackId &&
                                          playing)
                                      ? true
                                      : false,
                                )
                              : SeriesTrackListImageWidget(
                                  audioTrack: tracksList[index],
                                  tap: () {
                                    getIt<PageManager>().loadPlaylist(tracksList, index);
                                    widget.panelFunction(false);
                                  },
                                  favoriteTap: () async {
                                    if (isTrackFavorited(tracksList[index].trackId)) {
                                      removeFavorite(tracksList[index].trackId);
                                    } else {
                                      addTrackToFavorites(tracksList[index].trackId);
                                    }
                                    setState(() {});
                                  },
                                  favorite: isTrackFavorited(tracksList[index].trackId),
                                ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                          height: 1.0,
                          color: seriesDividerColor,
                        );
                      },
                    )
                  : _buildShimmerListViewImage("0"),
              if (trackListLoading || tracksList.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
                  child: Divider(
                    height: 1.0,
                    color: Colors.grey,
                  ),
                ),
            ]),
          ),
        ],
      ),
    ));
  }

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

Widget _buildShimmerListViewImage(String type) {
  return ListView.separated(
    physics: NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 300.h),
    itemCount: 3,
    itemBuilder: (BuildContext context, int index) {
      return Padding(
          padding: EdgeInsets.fromLTRB(0, 8.h, 0, 8.h),
          child: type == "1"
              ? ShimmerSeriesTrackListImageWidget()
              : ShimmerSeriesTrackListWidget());
    },
    separatorBuilder: (BuildContext context, int index) {
      return Divider(
        height: 1.0,
        color: Colors.grey,
      );
    },
  );
}
