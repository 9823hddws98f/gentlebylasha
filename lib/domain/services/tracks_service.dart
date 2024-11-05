import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '/domain/models/block_item/audio_track.dart';
import '/utils/common_extensions.dart';

class TracksService {
  TracksService._();
  static TracksService instance = TracksService._();

  final _collection = FirebaseFirestore.instance.collection('tracks');

  Future<AudioTrack> getById(String id) =>
      _collection.doc(id).get().then((doc) => doc.data() != null
          ? AudioTrack.fromMap(doc.data()!)
          : throw Exception('track not found'));

  Future<List<AudioTrack>> getByIds(List<String> trackIds) {
    if (trackIds.isEmpty) return Future.value([]);

    return _collection.where('id', whereIn: trackIds).get().then((snapshot) {
      final tracks = snapshot.docs.map((doc) => AudioTrack.fromMap(doc.data())).toList();

      // Sort tracks to match original trackIds order
      tracks.sort((a, b) => trackIds.indexOf(a.id).compareTo(trackIds.indexOf(b.id)));

      return tracks;
    });
  }

  Future<List<AudioTrack>> searchTracks(String query) async {
    if (query.isEmpty) return [];

    try {
      final normalizedQuery = query.toLowerCase();
      final firstChar = query.substring(0, 1).toUpperCase();
      final queryEnd = '$firstChar\uf8ff';

      // Get title matches
      final titleSnapshot = await _collection
          .where('title', isGreaterThanOrEqualTo: firstChar)
          .where('title', isLessThanOrEqualTo: queryEnd)
          .get();

      // Filter documents locally for case-insensitive matching
      final filteredDocs = titleSnapshot.docs.where((doc) {
        final data = doc.data();
        final title = data['title']?.toString().toLowerCase() ?? '';
        return title.contains(normalizedQuery);
      }).toList();

      if (filteredDocs.isNotEmpty) {
        return filteredDocs.map((doc) => AudioTrack.fromMap(doc.data())).toList();
      }

      // If no title matches, perform the speaker query
      final speakerSnapshot = await _collection
          .where('speaker', isGreaterThanOrEqualTo: firstChar)
          .where('speaker', isLessThanOrEqualTo: queryEnd)
          .get();

      return speakerSnapshot.docs.map((doc) => AudioTrack.fromMap(doc.data())).toList();
    } catch (e) {
      e.logDebug();
      return [];
    }
  }
}
