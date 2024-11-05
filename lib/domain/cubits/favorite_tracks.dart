import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '/domain/blocs/user/user_bloc.dart';
import '/domain/services/activity_log_service.dart';
import '/utils/get.dart';

/// Cubit for managing favorite tracks using Firestore
class FavoritesTracksCubit extends Cubit<List<String>> with ActivityLogger {
  static FavoritesTracksCubit instance = FavoritesTracksCubit._();
  FavoritesTracksCubit._() : super([]);

  final _collection = FirebaseFirestore.instance.collection('favorites');

  final _userBloc = Get.the<UserBloc>();
  String get _userId => _userBloc.state.user.id;

  Future<void> init() => _fetchFavorites();

  /// Adds a track to favorites in Firestore
  Future<void> addTrackToFavorites(String trackId) async {
    final currentFavorites = List<String>.from(state);
    if (!currentFavorites.contains(trackId)) {
      currentFavorites.add(trackId);
      emit(currentFavorites);
      await _updateFavorites(currentFavorites);
      logActivity(ActivityType.favorite, 'Added $trackId to favorites');
    }
  }

  /// Removes a track from favorites in Firestore
  Future<void> removeFavorite(String trackId) async {
    final currentFavorites = List<String>.from(state);
    if (currentFavorites.contains(trackId)) {
      currentFavorites.remove(trackId);
      emit(currentFavorites);
      await _updateFavorites(currentFavorites);
      logActivity(ActivityType.favorite, 'Removed $trackId from favorites');
    }
  }

  /// Fetches the favorites from Firestore
  Future<void> _fetchFavorites() async {
    try {
      final docSnapshot = await _collection.doc(_userId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final favorites = List<String>.from(data?['favorites'] ?? []);
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
      await _collection.doc(_userId).set({'favorites': favList});
    } catch (e) {
      if (kDebugMode) {
        print('Error updating favorites: $e');
      }
    }
  }
}
