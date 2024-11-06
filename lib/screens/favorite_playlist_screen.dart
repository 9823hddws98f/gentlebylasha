import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/domain/blocs/user/app_user.dart';
import '/domain/models/block_item/audio_playlist.dart';
import '/domain/services/language_constants.dart';
import '/utils/colors.dart';
import '/utils/global_functions.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/custom_tab_button.dart';
import '../widgets/blocks/playlist_block_item.dart';

class FavoritePlaylistScreen extends StatefulWidget {
  const FavoritePlaylistScreen({super.key});

  @override
  State<FavoritePlaylistScreen> createState() => _FavoritePlaylistScreenState();
}

class _FavoritePlaylistScreenState extends State<FavoritePlaylistScreen>
    with Translation {
  bool exception = false;
  bool isLoading = true;
  List<AudioPlaylist> favoritePlaylist = [];
  StreamSubscription<DocumentSnapshot>? favoritesSubscription;
  List<String> favoritesPlayList = [];
  bool favoritePlayListLoading = false;

  @override
  void initState() {
    super.initState();
    getFavPlayListArray();
    fetchFavoriteTracks();
  }

  Future<void> getFavPlayListArray() async {
    favoritesPlayList = await getFavoritePlayListFromSharedPref();
    setState(() {});
  }

  // Call this function to start listening for changes to the favorites array
  Future<void> startListeningToFavoritePlaylist() async {
    AppUser user = await getUser();
    final favoritesCollection =
        FirebaseFirestore.instance.collection('favorites_playlist');
    final userFavoritesDocRef = favoritesCollection.doc(user.id);

    favoritesSubscription = userFavoritesDocRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final favoritesData = snapshot.data();
        List<String> favorites = List.from(favoritesData!['playlist']);
        updateFavoritesList(favorites);
      }
    });
  }

  // Call this function to stop listening for changes to the favorites array
  void stopListeningToFavorites() {
    favoritesSubscription?.cancel();
  }

  Future<void> removePlayListFavorites(String blockId) async {
    setState(() {
      favoritePlayListLoading = true;
    });

    try {
      AppUser user = await getUser();
      final favoritesRef =
          FirebaseFirestore.instance.collection('favorites_playlist').doc(user.id);
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

// Update the favoriteList based on the updated favorites array
  void updateFavoritesList(List<String> favorites) async {
    favoritePlaylist.clear();

    if (favorites.isNotEmpty) {
      final tracksCollection = FirebaseFirestore.instance.collection('published_blocks');
      final batchSize = 10;
      final totalFavorites = favorites.length;
      final batchCount = (totalFavorites / batchSize).ceil();

      for (var i = 0; i < batchCount; i++) {
        final start = i * batchSize;
        final end = (i + 1) * batchSize;
        final batchFavorites =
            favorites.sublist(start, end < totalFavorites ? end : totalFavorites);

        final tracksQuerySnapshot = await tracksCollection
            .where(
              FieldPath.documentId,
              whereIn: batchFavorites,
            )
            .get();

        for (var doc in tracksQuerySnapshot.docs) {
          Map<String, dynamic> data = doc.data();
          AudioPlaylist playlist = AudioPlaylist.fromMap(data);
          favoritePlaylist.add(playlist);
        }
      }
    }

    setState(() {
      exception = false;
      isLoading = false;
    });
  }

// Modify the fetchFavoriteTracks function to start and stop the favorites listener
  Future<void> fetchFavoriteTracks() async {
    setState(() {
      exception = false;
      isLoading = true;
    });

    try {
      await startListeningToFavoritePlaylist();
    } on FirebaseException {
      isLoading = false;
      exception = true;
      // Handle Firebase exception
    } catch (e) {
      isLoading = false;
      exception = true;
      // Handle other exceptions
    }

    setState(() {});
  }

// Call the stopListeningToFavorites function to stop the listener when it's no longer needed
  @override
  void dispose() {
    stopListeningToFavorites();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: FIX PAGE NOT RESPONSIVE
    return AppScaffold(
      appBar: (text, isMobile) => AdaptiveAppBar(
        title: tr.favoritePlaylist,
      ),
      body: (context, isMobile) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
          ),
          if (favoritePlaylist.isNotEmpty && !isLoading) ...[
            Expanded(
                child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 165),
              child: Column(
                children: [
                  for (int index = 0; index < favoritePlaylist.length; index++)
                    PlaylistBlockItem(playlist: favoritePlaylist[index]),
                ],
              ),
            ))
          ] else if (favoritePlaylist.isEmpty && exception) ...[
            Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                "Something went wrong",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                height: 20,
              ),
              CustomTabButton(
                  title: "Retry",
                  onPress: () {
                    fetchFavoriteTracks();
                  },
                  color: Colors.white,
                  textColor: textColor)
            ]))
          ] else if (favoritePlaylist.isEmpty && !exception && !isLoading) ...[
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Icon(
                  Icons.favorite_border,
                  size: 40,
                )),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "You have not added any playlists to favorites",
                  style: TextStyle(fontSize: 16),
                )
              ],
            ))
          ] else ...[
            _buildShimmerListView()
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerListView() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(
            6,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: PlaylistBlockItem.shimmer(),
            ),
          ),
        ),
      ),
    );
  }
}
