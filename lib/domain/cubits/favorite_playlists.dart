import 'package:cloud_firestore/cloud_firestore.dart';

import '/domain/blocs/user/user_bloc.dart';
import '/domain/services/activity_log_service.dart';
import '/utils/get.dart';
import 'favorite_ids.dart';

/// Favorite playlists of the signed-in user, stored in `favorites_playlists/{uid}`.
class FavoritePlaylistsCubit extends FavoriteIdsCubit with ActivityLogger {
  static FavoritePlaylistsCubit instance = FavoritePlaylistsCubit._();
  FavoritePlaylistsCubit._();

  final _collection = FirebaseFirestore.instance.collection('favorites_playlists');

  final _userBloc = Get.the<UserBloc>();
  String get _userId => _userBloc.state.user.id;

  Future<void> init() => _fetchFavorites();

  @override
  Future<void> save(List<String> ids) => _collection.doc(_userId).set({'playlists': ids});

  Future<void> addPlaylistToFavorites(String playlistId) async {
    if (await add(playlistId)) {
      logActivity(ActivityType.favorite, 'Added playlist $playlistId to favorites');
    }
  }

  Future<void> removePlaylist(String playlistId) async {
    if (await remove(playlistId)) {
      logActivity(ActivityType.favorite, 'Removed playlist $playlistId from favorites');
    }
  }

  Future<void> _fetchFavorites() async {
    try {
      final docSnapshot = await _collection.doc(_userId).get();
      emit(List<String>.from(docSnapshot.data()?['playlists'] ?? []));
    } catch (e) {
      emit([]);
    }
  }
}
