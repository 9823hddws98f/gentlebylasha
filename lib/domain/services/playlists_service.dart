import 'package:cloud_firestore/cloud_firestore.dart';

import '/domain/models/block_item/audio_playlist.dart';

class PlaylistsService {
  PlaylistsService._();
  static PlaylistsService instance = PlaylistsService._();

  final _collection = FirebaseFirestore.instance.collection('playlists');

  Future<AudioPlaylist> getById(String id) =>
      _collection.doc(id).get().then((doc) => doc.data() != null
          ? AudioPlaylist.fromMap(doc.data()!)
          : throw Exception('playlist not found'));

  Future<List<AudioPlaylist>> getByIds(List<String> playlistIds) {
    if (playlistIds.isEmpty) return Future.value([]);

    return _collection.where('id', whereIn: playlistIds).get().then((snapshot) {
      final playlists =
          snapshot.docs.map((doc) => AudioPlaylist.fromMap(doc.data())).toList();

      // Sort playlists to match original playlistIds order
      playlists.sort(
        (a, b) => playlistIds.indexOf(a.id).compareTo(playlistIds.indexOf(b.id)),
      );

      return playlists;
    });
  }
}
