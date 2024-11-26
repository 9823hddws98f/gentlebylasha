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

      // Get all documents and filter client-side
      final snapshot = await _collection
          .limit(100) // Adjust limit as needed
          .get();

      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        final title = data['title']?.toString().toLowerCase() ?? '';
        final speaker = data['speaker']?.toString().toLowerCase() ?? '';
        final writer = data['writer']?.toString().toLowerCase() ?? '';

        return title.contains(normalizedQuery) ||
            speaker.contains(normalizedQuery) ||
            writer.contains(normalizedQuery);
      }).toList();

      return filteredDocs.map((doc) => AudioTrack.fromMap(doc.data())).toList();
    } catch (e) {
      e.logDebug();
      return [];
    }
  }
}
