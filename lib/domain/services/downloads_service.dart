import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/domain/models/block_item/audio_track.dart';
import '/domain/services/tracks_service.dart';

/// Offline downloads, kept per account: the audio files live in
/// `<app support>/downloads/<uid>/` and the list of tracks in the preferences
/// under `downloads_<uid>`. A stored track's trackUrl is the file name in that
/// folder (or an absolute path, for downloads from before they were per
/// account); [getSavedTracks] returns tracks with the full path.
class DownloadsService {
  DownloadsService({Future<Directory> Function()? root})
      : _root = root ?? getApplicationSupportDirectory;

  static final DownloadsService instance = DownloadsService();

  /// Downloads exist only in the iOS and Android apps.
  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  final Future<Directory> Function() _root;

  /// Where all downloads were listed before they were per account.
  static const legacyKey = 'saved_tracks';

  static String indexKey(String uid) => 'downloads_$uid';

  /// Full path of a stored file: [stored] is a file name in [dir], or already
  /// an absolute path.
  static String resolvePath(String dir, String stored) =>
      stored.startsWith('/') ? stored : '$dir/$stored';

  Future<String> _dirOf(String uid) async => '${(await _root()).path}/downloads/$uid';

  static AudioTrack? _parse(String json) {
    try {
      return AudioTrack.fromJson(json);
    } catch (e) {
      debugPrint('Skipping an unreadable download: $e');
      return null;
    }
  }

  // Reading and writing the list happen without an await in between, so two
  // downloads finishing at the same time don't drop each other.
  List<AudioTrack> _read(SharedPreferences prefs, String key) => [
        for (final json in prefs.getStringList(key) ?? const <String>[])
          if (_parse(json) case final track?) track,
      ];

  Future<void> _write(SharedPreferences prefs, String uid, List<AudioTrack> tracks) =>
      prefs.setStringList(indexKey(uid), [for (final t in tracks) t.toJson()]);

  /// Downloads from before they were per account go to the first account
  /// that loads its downloads on this device.
  Future<void> _adoptLegacy(SharedPreferences prefs, String uid) async {
    if (!prefs.containsKey(legacyKey)) return;
    final tracks = _read(prefs, indexKey(uid));
    for (final track in _read(prefs, legacyKey)) {
      if (!tracks.any((t) => t.id == track.id)) tracks.add(track);
    }
    await _write(prefs, uid, tracks);
    await prefs.remove(legacyKey);
  }

  /// The downloads of [uid] whose file is still there, with trackUrl set to
  /// the full path. Entries whose file is gone are dropped from the list.
  Future<List<AudioTrack>> getSavedTracks(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await _adoptLegacy(prefs, uid);
    final dir = await _dirOf(uid);
    final present = <AudioTrack>[];
    final missing = <String>{};
    for (final track in _read(prefs, indexKey(uid))) {
      final path = resolvePath(dir, track.trackUrl);
      if (await File(path).exists()) {
        present.add(track.copyWith(trackUrl: path));
      } else {
        missing.add(track.id);
      }
    }
    if (missing.isNotEmpty) {
      await _write(
        prefs,
        uid,
        _read(prefs, indexKey(uid))..removeWhere((t) => missing.contains(t.id)),
      );
    }
    return present;
  }

  /// Downloads the audio of [track] for [uid].
  Future<void> saveTrack(String uid, AudioTrack track) async {
    track = (await TracksService.instance.withAudioUrls([track])).first;
    // The download URL carries its own access token, so no Storage rules apply.
    final response = await http.get(Uri.parse(track.trackUrl));
    if (response.statusCode != 200) {
      throw HttpException('Download failed with status ${response.statusCode}');
    }
    await storeTrack(uid, track, response.bodyBytes);
  }

  /// Saves [bytes] as the audio of [track] and adds it to the downloads of [uid].
  Future<void> storeTrack(String uid, AudioTrack track, List<int> bytes) async {
    final dir = await _dirOf(uid);
    await Directory(dir).create(recursive: true);
    final fileName = '${track.id}.mp3';
    await File('$dir/$fileName').writeAsBytes(bytes, flush: true);

    final prefs = await SharedPreferences.getInstance();
    final tracks = _read(prefs, indexKey(uid))
      ..removeWhere((t) => t.id == track.id)
      ..add(track.copyWith(trackUrl: fileName));
    await _write(prefs, uid, tracks);
  }

  Future<void> removeTrack(String uid, String trackId) async {
    final prefs = await SharedPreferences.getInstance();
    final tracks = _read(prefs, indexKey(uid));
    final removed = tracks.where((t) => t.id == trackId).toList();
    await _write(prefs, uid, tracks..removeWhere((t) => t.id == trackId));
    final dir = await _dirOf(uid);
    for (final track in removed) {
      await _deleteFile(resolvePath(dir, track.trackUrl));
    }
  }

  /// Deletes every download of [uid]: the files and the list.
  Future<void> removeAll(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await _adoptLegacy(prefs, uid);
    final tracks = _read(prefs, indexKey(uid));
    await prefs.remove(indexKey(uid));
    final dir = await _dirOf(uid);
    // Older downloads can live outside the folder of the account.
    for (final track in tracks) {
      await _deleteFile(resolvePath(dir, track.trackUrl));
    }
    final folder = Directory(dir);
    if (await folder.exists()) await folder.delete(recursive: true);
  }

  Future<void> _deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('Deleting a download failed: $e');
    }
  }
}
