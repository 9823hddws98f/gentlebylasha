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

    // Firestore allows at most 30 values in a whereIn query.
    return Future.wait([
      for (var i = 0; i < playlistIds.length; i += 30)
        _collection
            .where('id', whereIn: playlistIds.sublist(i, (i + 30).clamp(0, playlistIds.length)))
            .get(),
    ]).then((snapshots) {
      final playlists = [
        for (final snapshot in snapshots)
          for (final doc in snapshot.docs) AudioPlaylist.fromMap(doc.data()),
      ];

      // Sort playlists to match original playlistIds order
      playlists.sort(
        (a, b) => playlistIds.indexOf(a.id).compareTo(playlistIds.indexOf(b.id)),
      );

      return playlists;
    });
  }
}
