import 'package:cloud_firestore/cloud_firestore.dart';

import '/domain/blocs/user/user_bloc.dart';
import '/domain/services/activity_log_service.dart';
import '/utils/get.dart';
import 'favorite_ids.dart';

/// Favorite tracks of the signed-in user, stored in `favorites/{uid}`.
class FavoritesTracksCubit extends FavoriteIdsCubit with ActivityLogger {
  static FavoritesTracksCubit instance = FavoritesTracksCubit._();
  FavoritesTracksCubit._();

  final _collection = FirebaseFirestore.instance.collection('favorites');

  final _userBloc = Get.the<UserBloc>();
  String get _userId => _userBloc.state.user.id;

  Future<void> init() => _fetchFavorites();

  @override
  Future<void> save(List<String> ids) => _collection.doc(_userId).set({'favorites': ids});

  Future<void> addTrackToFavorites(String trackId) async {
    if (await add(trackId)) logActivity(ActivityType.favorite, 'Added $trackId to favorites');
  }

  Future<void> removeFavorite(String trackId) async {
    if (await remove(trackId)) {
      logActivity(ActivityType.favorite, 'Removed $trackId from favorites');
    }
  }

  Future<void> _fetchFavorites() async {
    try {
      final docSnapshot = await _collection.doc(_userId).get();
      emit(List<String>.from(docSnapshot.data()?['favorites'] ?? []));
    } catch (e) {
      emit([]);
    }
  }
}
