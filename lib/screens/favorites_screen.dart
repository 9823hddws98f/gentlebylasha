import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/domain/blocs/user/app_user.dart';
import '/domain/models/block_item/audio_track.dart';
import '/domain/services/language_constants.dart';
import '/domain/services/service_locator.dart';
import '/page_manager.dart';
import '/utils/colors.dart';
import '/utils/global_functions.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/custom_tab_button.dart';
import '/widgets/track_list_item.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with Translation {
  bool exception = false;
  bool isLoading = true;
  List<AudioTrack> favoriteList = [];
  StreamSubscription<DocumentSnapshot>? favoritesSubscription;

  @override
  void initState() {
    super.initState();
    fetchFavoriteTracks();
  }

  // Call this function to start listening for changes to the favorites array
  Future<void> startListeningToFavorites() async {
    AppUser user = await getUser();
    final favoritesCollection = FirebaseFirestore.instance.collection('favorites');
    final userFavoritesDocRef = favoritesCollection.doc(user.id);

    favoritesSubscription = userFavoritesDocRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final favoritesData = snapshot.data();
        List<String> favorites = List.from(favoritesData!['favorites']);
        updateFavoritesList(favorites);
      }
    });
  }

  // Call this function to stop listening for changes to the favorites array
  void stopListeningToFavorites() {
    favoritesSubscription?.cancel();
  }

// Update the favoriteList based on the updated favorites array
  void updateFavoritesList(List<String> favorites) async {
    favoriteList.clear();

    if (favorites.isNotEmpty) {
      final tracksCollection = FirebaseFirestore.instance.collection('tracks');
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
          AudioTrack track = AudioTrack.fromMap(doc.data());
          favoriteList.add(track);
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
      await startListeningToFavorites();
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
    // TODO: CLEANUP
    return AppScaffold(
      appBar: (text, isMobile) => AdaptiveAppBar(
        title: tr.favoriteList,
      ),
      body: (context, isMobile) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
          ),
          if (favoriteList.isNotEmpty && !isLoading) ...[
            Expanded(
                child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 165),
              child: GridView.builder(
                  itemCount: favoriteList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.81),
                  itemBuilder: (BuildContext context, int index) {
                    return TrackListItemSmall(
                      imageUrl: favoriteList[index].imageBackground,
                      mp3Name: favoriteList[index].title,
                      mp3Category: 'ERROR!', // TODO: FIX
                      mp3Duration: favoriteList[index].durationString,
                      tap: () {
                        getIt<PageManager>().playSinglePlaylist(
                          MediaItem(
                            id: favoriteList[index].id,
                            album: favoriteList[index].title,
                            title: favoriteList[index].title,
                            displayDescription: favoriteList[index].description,
                            artUri: Uri.parse(favoriteList[index].imageBackground),
                            extras: {
                              'id': favoriteList[index].id,
                              'url': favoriteList[index].trackUrl,
                            },
                          ),
                          favoriteList[index].id,
                        );
                        // TODO:     widget.panelFunction();
                      },
                    );
                  }),
            ))
          ] else if (favoriteList.isEmpty && exception) ...[
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
          ] else if (favoriteList.isEmpty && !exception && !isLoading) ...[
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
                  "You have not added any favorites yet",
                  style: TextStyle(fontSize: 16),
                )
              ],
            ))
          ] else ...[
            // _buildShimmerListView()
          ],
        ],
      ),
    );
  }

  // Widget _buildShimmerListView() {
  //   return Expanded(
  //       child: SingleChildScrollView(
  //     child: GridView.builder(
  //         itemCount: 12,
  //         shrinkWrap: true,
  //         physics: NeverScrollableScrollPhysics(),
  //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //             crossAxisCount: 2,
  //             crossAxisSpacing: 16,
  //             mainAxisSpacing: 16,
  //             childAspectRatio: 0.81),
  //         itemBuilder: (BuildContext context, int index) {
  //           return TrackListItemSmall.shimmer();
  //         }),
  //   ));
  // }
}
