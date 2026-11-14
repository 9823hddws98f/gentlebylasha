import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '/domain/models/block_item/audio_track.dart';
import '/utils/common_extensions.dart';
import '/utils/get.dart';
import 'analytics_service.dart';

class TracksService {
  TracksService._();
  static TracksService instance = TracksService._();

  final _collection = FirebaseFirestore.instance.collection('tracks');

  /// Audio URLs of premium tracks; only readable with premium (firestore.rules).
  final _audio = FirebaseFirestore.instance.collection('track_audio');

  /// Fills in the audio URL of premium tracks, which is kept out of `tracks`.
  /// Throws when the user may not read it.
  Future<List<AudioTrack>> withAudioUrls(List<AudioTrack> tracks) async {
    final missing = tracks.where((t) => t.trackUrl.isEmpty).map((t) => t.id).toList();
    if (missing.isEmpty) return tracks;
    final urls = <String, String>{};
    for (var i = 0; i < missing.length; i += 30) {
      final chunk = missing.sublist(i, (i + 30).clamp(0, missing.length));
      final snap = await _audio.where(FieldPath.documentId, whereIn: chunk).get();
      for (final doc in snap.docs) {
        urls[doc.id] = doc.data()['url'] as String;
      }
    }
    return [
      for (final t in tracks)
        t.trackUrl.isEmpty && urls[t.id] != null ? t.copyWith(trackUrl: urls[t.id]) : t,
    ];
  }

  final _analytics = Get.the<AnalyticsService>();

  Future<AudioTrack> getById(String id) => _collection.doc(id).get().then((doc) =>
      doc.data() != null ? AudioTrack.fromMap(doc.data()!) : throw Exception('track not found'));

  Future<List<AudioTrack>> getByIds(List<String> trackIds) {
    if (trackIds.isEmpty) return Future.value([]);

    // Firestore allows at most 30 values in a whereIn query.
    return Future.wait([
      for (var i = 0; i < trackIds.length; i += 30)
        _collection
            .where('id', whereIn: trackIds.sublist(i, (i + 30).clamp(0, trackIds.length)))
            .get(),
    ]).then((snapshots) {
      final tracks = [
        for (final snapshot in snapshots)
          for (final doc in snapshot.docs) AudioTrack.fromMap(doc.data()),
      ];

      // Sort tracks to match original trackIds order
      tracks.sort((a, b) => trackIds.indexOf(a.id).compareTo(trackIds.indexOf(b.id)));

      return tracks;
    });
  }

  /// Every track, read once per [_searchCacheAge] instead of on every search
  /// keystroke. Filtered on the device: Firestore has no text search.
  List<Map<String, dynamic>>? _searchCache;
  DateTime _searchCachedAt = DateTime(0);
  static const _searchCacheAge = Duration(minutes: 10);

  Future<List<Map<String, dynamic>>> _searchableTracks() async {
    final cache = _searchCache;
    if (cache != null && DateTime.now().difference(_searchCachedAt) < _searchCacheAge) {
      return cache;
    }
    final snapshot = await _collection.get();
    _searchCachedAt = DateTime.now();
    return _searchCache = [for (final doc in snapshot.docs) doc.data()];
  }

  /// Whether a track document matches [normalizedQuery] (lowercase). Looks at
  /// the Dutch title too, since that is the title Dutch users see.
  @visibleForTesting
  static bool matchesSearch(Map<String, dynamic> data, String normalizedQuery) =>
      const ['title', 'titleNl', 'speaker', 'writer'].any(
        (field) => data[field]?.toString().toLowerCase().contains(normalizedQuery) ?? false,
      );

  Future<List<AudioTrack>> searchTracks(String query) async {
    _analytics.logSearch(query);

    if (query.isEmpty) return [];

    try {
      final normalizedQuery = query.toLowerCase();

      final tracks = await _searchableTracks();
      return [
        for (final data in tracks)
          if (matchesSearch(data, normalizedQuery)) AudioTrack.fromMap(data),
      ];
    } catch (e) {
      e.logDebug();
      return [];
    }
  }
}
