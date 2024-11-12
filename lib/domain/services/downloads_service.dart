import 'package:file_saver/file_saver.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/domain/models/block_item/audio_track.dart';

class DownloadsService {
  DownloadsService._();

  static DownloadsService instance = DownloadsService._();

  final _fileSaver = FileSaver.instance;
  final _prefs = SharedPreferences.getInstance();
  static const _savedTracksKey = 'saved_tracks';

  Future<List<AudioTrack>> getSavedTracks() async {
    final prefs = await _prefs;
    final jsonList = prefs.getStringList(_savedTracksKey) ?? [];
    return jsonList.map((json) => AudioTrack.fromJson(json)).toList();
  }

  Future<void> saveTrack(AudioTrack track) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(track.trackUrl);
      final metadata = await ref.getMetadata();
      final int fileSize = metadata.size ?? 0;

      final bytes = await ref.getData(fileSize);

      if (bytes == null) throw Exception('Failed to download file');

      final fileName = '${track.id}.mp3';
      final localPath = await _fileSaver.saveFile(
        name: fileName,
        bytes: bytes,
      );

      // Create a modified track with local path
      final savedTrack = track.copyWith(
        trackUrl: localPath,
      );

      final prefs = await _prefs;
      final savedTracks = await getSavedTracks();

      if (!savedTracks.any((t) => t.id == track.id)) {
        savedTracks.add(savedTrack);
        await prefs.setStringList(
          _savedTracksKey,
          savedTracks.map((t) => t.toJson()).toList(),
        );
      }
    } catch (e) {
      throw Exception('Failed to download track: $e');
    }
  }

  Future<void> removeTrack(String trackId) async {
    final prefs = await _prefs;
    final savedTracks = await getSavedTracks();

    savedTracks.removeWhere((track) => track.id == trackId);
    await prefs.setStringList(
      _savedTracksKey,
      savedTracks.map((t) => t.toJson()).toList(),
    );
  }

  Future<bool> isTrackDownloaded(String trackId) async {
    final savedTracks = await getSavedTracks();
    return savedTracks.any((track) => track.id == trackId);
  }

  Future<void> removeAll() async {
    final prefs = await _prefs;
    await prefs.remove(_savedTracksKey);
  }
}
