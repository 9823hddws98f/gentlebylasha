import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '/language_constants.dart';
import '/models/user_model.dart';
import '/utils/colors.dart';
import '/utils/global_functions.dart';
import '/widgets/custom_tab_button.dart';
import '/widgets/track_list_item.dart';
import '../models/audiofile_model.dart';
import '../page_manager.dart';
import '../services/service_locator.dart';
import '../widgets/shimmerwidgets/shimmer_mp3_card_tracklist_item.dart';
import '../widgets/topbar_widget.dart';

class FavoritesScreen extends StatefulWidget {
  final Function panelFunction;
  const FavoritesScreen({super.key, required this.panelFunction});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
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
    UserModel user = await getUser();
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
      final tracksCollection = FirebaseFirestore.instance.collection('Tracks');
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
          AudioTrack track = AudioTrack.fromFirestore(doc);
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
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
            child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TopBar(
                        heading: translation(context).favoriteList,
                        onPress: () {
                          Navigator.pop(context);
                        }),
                    SizedBox(
                      height: 20.h,
                    ),
                    if (favoriteList.isNotEmpty && !isLoading) ...[
                      Expanded(
                          child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: 165.h),
                        child: GridView.builder(
                            itemCount: favoriteList.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16.w,
                                mainAxisSpacing: 16.h,
                                childAspectRatio: 0.81),
                            itemBuilder: (BuildContext context, int index) {
                              return TrackListItemSmall(
                                imageUrl: favoriteList[index].imageBackground,
                                mp3Name: favoriteList[index].title,
                                mp3Category:
                                    favoriteList[index].categories[0].categoryName,
                                mp3Duration: favoriteList[index].length,
                                tap: () {
                                  getIt<PageManager>().playSinglePlaylist(
                                      MediaItem(
                                        id: favoriteList[index].trackId,
                                        album: favoriteList[index].title,
                                        title: favoriteList[index].title,
                                        displayDescription:
                                            favoriteList[index].description,
                                        artUri: Uri.parse(
                                            favoriteList[index].imageBackground),
                                        extras: {
                                          'url': favoriteList[index].trackUrl,
                                          'id': favoriteList[index].trackId,
                                          'categories': favoriteList[index].categories
                                        },
                                      ),
                                      favoriteList[index].trackId);
                                  widget.panelFunction();
                                },
                              );
                            }),
                      ))
                    ] else if (favoriteList.isEmpty && exception) ...[
                      Expanded(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Text(
                              "Something went wrong",
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            SizedBox(
                              height: 20.h,
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
                            size: 40.h,
                          )),
                          SizedBox(
                            height: 5.h,
                          ),
                          Text(
                            "You have not added any favorites yet",
                            style: TextStyle(fontSize: 16.sp),
                          )
                        ],
                      ))
                    ] else ...[
                      _buildShimmerListView()
                    ],
                  ],
                ))),
      ),
    );
  }

  Widget _buildShimmerListView() {
    return Expanded(
        child: SingleChildScrollView(
      child: GridView.builder(
          itemCount: 12,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.81),
          itemBuilder: (BuildContext context, int index) {
            return ShimmerTrackListItemSmall();
          }),
    ));
  }
}
