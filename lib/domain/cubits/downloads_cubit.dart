import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '/domain/models/block_item/audio_track.dart';
import '/domain/services/downloads_service.dart';
import '/utils/get.dart';

/// The offline downloads of the signed-in account. Follows sign-in and
/// sign-out; logout deletes the downloads of the account (see logout()).
class DownloadsCubit extends Cubit<List<AudioTrack>> {
  static DownloadsCubit instance = DownloadsCubit._();
  DownloadsCubit._() : super(const []) {
    if (DownloadsService.supported) {
      _authSubscription =
          FirebaseAuth.instance.authStateChanges().listen((user) => _load(user?.uid));
    }
  }

  final _service = Get.the<DownloadsService>();
  StreamSubscription<User?>? _authSubscription;

  /// The account whose downloads are shown.
  String? _uid;

  String? get _currentUid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _load(String? uid) async {
    _uid = uid;
    if (uid == null) return emit(const []);
    try {
      final tracks = await _service.getSavedTracks(uid);
      if (_uid == uid) emit(tracks);
    } catch (e) {
      debugPrint('Loading downloads failed: $e');
      if (_uid == uid) emit(const []);
    }
  }

  Future<void> downloadTrack(AudioTrack track) async {
    final uid = _currentUid;
    if (uid == null) throw StateError('Downloading needs a signed-in account');
    await _service.saveTrack(uid, track);
    if (_currentUid == uid) await _load(uid);
  }

  Future<void> removeTrack(String trackId) async {
    final uid = _currentUid;
    if (uid == null) return;
    await _service.removeTrack(uid, trackId);
    if (_uid == uid) emit(state.where((track) => track.id != trackId).toList());
  }

  /// Deletes every download of the signed-in account. Never throws, so a
  /// logout always goes through.
  Future<void> removeAll() async {
    final uid = _currentUid;
    if (uid != null && DownloadsService.supported) {
      try {
        await _service.removeAll(uid);
      } catch (e) {
        debugPrint('Deleting downloads failed: $e');
      }
    }
    emit(const []);
  }

  bool isTrackDownloaded(String trackId) {
    return state.any((track) => track.id == trackId);
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
