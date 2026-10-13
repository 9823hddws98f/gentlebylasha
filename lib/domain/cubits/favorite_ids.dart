import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '/domain/services/language_cubit.dart';
import '/helper/global_functions.dart';
import '/utils/get.dart';

/// Ids the user marked as favorite (tracks or playlists). A change shows
/// right away; when saving it fails, it is undone and the user is told.
abstract class FavoriteIdsCubit extends Cubit<List<String>> {
  FavoriteIdsCubit() : super(const []);

  /// Stores [ids] as the favorites of the signed-in user.
  @protected
  Future<void> save(List<String> ids);

  /// Tells the user that a change could not be saved.
  @protected
  void onSaveFailed() => showToast(Get.the<LanguageCubit>().translation.favoriteUpdateFailed);

  void reset() => emit(const []);

  /// Adds [id]; true when that was a change and it was saved.
  Future<bool> add(String id) => _change(id, favorite: true);

  /// Removes [id]; true when that was a change and it was saved.
  Future<bool> remove(String id) => _change(id, favorite: false);

  Future<bool> _change(String id, {required bool favorite}) async {
    if (state.contains(id) == favorite) return false;
    final next = _with(state, id, favorite: favorite);
    emit(next);
    try {
      await save(next);
      return true;
    } catch (e) {
      debugPrint('Saving favorites failed: $e');
      // Undo only this change: another one may have happened meanwhile.
      if (state.contains(id) == favorite) emit(_with(state, id, favorite: !favorite));
      onSaveFailed();
      return false;
    }
  }

  static List<String> _with(List<String> ids, String id, {required bool favorite}) =>
      favorite ? [...ids, id] : [for (final other in ids) if (other != id) other];
}
