import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalyticsService {
  AnalyticsService._();

  static AnalyticsService instance = AnalyticsService._();

  final _firestore = FirebaseFirestore.instance;
  final _userId = FirebaseAuth.instance.currentUser?.uid;

  void logAudioPlay({
    required String trackId,
    String? playlistId,
  }) {
    final eventData = {
      'track_id': trackId,
      'playlist_id': playlistId,
    };
    _logEvent('audio_play', eventData);
  }

  void logAudioSeek({
    required String trackId,
    required Duration previousPosition,
    required Duration newPosition,
    required Duration totalDuration,
    String? playlistId,
  }) {
    final eventData = {
      'track_id': trackId,
      'previous_position_seconds': previousPosition.inSeconds,
      'new_position_seconds': newPosition.inSeconds,
      'total_duration_seconds': totalDuration.inSeconds,
      'playlist_id': playlistId,
    };
    _logEvent('audio_seek', eventData);
  }

  void logPlaylistLoad({
    required String playlistId,
    required int trackCount,
    required int startIndex,
  }) {
    final eventData = {
      'playlist_id': playlistId,
      'track_count': trackCount,
      'start_index': startIndex,
    };
    _logEvent('playlist_load', eventData);
  }

  void _logEvent(String eventName, Map<String, dynamic> eventData) {
    final eventPayload = {
      'uid': _userId,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'name': eventName,
      'data': eventData,
    };

    _firestore.collection('analytics').doc().set(eventPayload);
  }
}
