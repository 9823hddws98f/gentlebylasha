import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '/domain/models/block_item/audio_track.dart';
import '/domain/services/downloads_service.dart';
import '/utils/get.dart';

class DownloadsCubit extends Cubit<List<AudioTrack>> {
  static DownloadsCubit instance = DownloadsCubit._();
  DownloadsCubit._() : super([]);

  final _service = Get.the<DownloadsService>();

  Future<void> init() => _loadTracks();

  Future<void> _loadTracks() async {
    try {
      final tracks = await _service.getSavedTracks();
      emit(tracks);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading downloaded tracks: $e');
      }
      emit([]);
    }
  }

  Future<void> downloadTrack(AudioTrack track) async {
    try {
      await _service.saveTrack(track);
      await _loadTracks();
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading track: $e');
      }
      rethrow;
    }
  }

  Future<void> removeTrack(String trackId) async {
    try {
      await _service.removeTrack(trackId);
      final currentTracks = List<AudioTrack>.from(state);
      currentTracks.removeWhere((track) => track.id == trackId);
      emit(currentTracks);
    } catch (e) {
      if (kDebugMode) {
        print('Error removing track: $e');
      }
      rethrow;
    }
  }

  bool isTrackDownloaded(String trackId) {
    return state.any((track) => track.id == trackId);
  }
}
