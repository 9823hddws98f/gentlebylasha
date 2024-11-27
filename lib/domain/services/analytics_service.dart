import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();

  static AnalyticsService instance = AnalyticsService._();

  final analytics = FirebaseAnalytics.instance;

  void logAudioPlay(String trackId, String? playlistId) => _logEvent('audio_play', {
        'track_id': trackId,
        'playlist_id': playlistId ?? '',
      });

  void logAudioSeek(String trackId, Duration previousPosition, Duration newPosition,
          Duration totalDuration, String? playlistId) =>
      _logEvent('audio_seek', {
        'track_id': trackId,
        'previous_position_seconds': previousPosition.inSeconds,
        'new_position_seconds': newPosition.inSeconds,
        'total_duration_seconds': totalDuration.inSeconds,
        'playlist_id': playlistId ?? '',
      });

  void logPlaylistLoad(String playlistId, int trackCount, int startIndex) =>
      _logEvent('playlist_load', {
        'playlist_id': playlistId,
        'track_count': trackCount,
        'start_index': startIndex,
      });

  void logSearch(String query) => analytics.logSearch(searchTerm: query);

  void _logEvent(String eventName, Map<String, Object> eventData) {
    analytics.logEvent(name: eventName, parameters: eventData);
  }
}
