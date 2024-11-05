import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '/domain/blocs/user/user_bloc.dart';
import '/domain/services/activity_log_service.dart';
import '/utils/get.dart';

/// Cubit for managing favorite playlists using Firestore
class FavoritePlaylistsCubit extends Cubit<List<String>> with ActivityLogger {
  static FavoritePlaylistsCubit instance = FavoritePlaylistsCubit._();
  FavoritePlaylistsCubit._() : super([]);

  final _collection = FirebaseFirestore.instance.collection('favorites_playlists');

  final _userBloc = Get.the<UserBloc>();
  String get _userId => _userBloc.state.user.id;

  Future<void> init() => _fetchFavorites();

  /// Adds a playlist to favorites in Firestore
  Future<void> addPlaylistToFavorites(String playlistId) async {
    final currentFavorites = List<String>.from(state);
    if (!currentFavorites.contains(playlistId)) {
      currentFavorites.add(playlistId);
      emit(currentFavorites);
      await _updateFavorites(currentFavorites);
      logActivity(ActivityType.favorite, 'Added playlist $playlistId to favorites');
    }
  }

  /// Removes a playlist from favorites in Firestore
  Future<void> removePlaylist(String playlistId) async {
    final currentFavorites = List<String>.from(state);
    if (currentFavorites.contains(playlistId)) {
      currentFavorites.remove(playlistId);
      emit(currentFavorites);
      await _updateFavorites(currentFavorites);
      logActivity(ActivityType.favorite, 'Removed playlist $playlistId from favorites');
    }
  }

  /// Fetches the favorites from Firestore
  Future<void> _fetchFavorites() async {
    try {
      final docSnapshot = await _collection.doc(_userId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final favorites = List<String>.from(data?['playlists'] ?? []);
        emit(favorites);
      } else {
        emit([]);
      }
    } catch (e) {
      emit([]);
    }
  }

  /// Updates the favorites in Firestore
  Future<void> _updateFavorites(List<String> favList) async {
    try {
      await _collection.doc(_userId).set({'playlists': favList});
    } catch (e) {
      if (kDebugMode) {
        print('Error updating favorite playlists: $e');
      }
    }
  }
}
