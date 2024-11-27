import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

import '/domain/models/block_item/audio_playlist.dart';
import '/domain/models/block_item/audio_track.dart';
import '/domain/services/audio_panel_manager.dart';
import '/notifiers/progress_notifier.dart';
import '/notifiers/repeat_notifier.dart';
import '/utils/get.dart';
import 'analytics_service.dart';

class AudioManager {
  AudioManager._();
  static final instance = AudioManager._();

  final _audioHandler = Get.the<AudioHandler>();
  final _analytics = Get.the<AnalyticsService>();

  final List<StreamSubscription> _subscriptions = [];

  final currentMediaItemNotifier = ValueNotifier<MediaItem>(
    const MediaItem(id: '', title: ''),
  );

  final playlistIdNotifier = ValueNotifier<List<String>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

  // Current playlist block, (null if not playing a playlist)
  final currentPlaylistBlockNotifier = ValueNotifier<AudioPlaylist?>(null);
  bool get _isPlaylistPlaying => currentPlaylistBlockNotifier.value != null;

  bool _isInitialized = false;

  void init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    _listenToChangesInPlaylist();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
  }

  void playSinglePlaylist(MediaItem mediaItem, String trackId) {
    if (_isPlaylistPlaying || currentMediaItemNotifier.value.id != trackId) {
      currentPlaylistBlockNotifier.value = null;
      playlistIdNotifier.value = [];
      _audioHandler.addQueueItem(mediaItem);
    }
  }

  Future<void> loadPlaylist(
    AudioPlaylist playlist,
    List<AudioTrack> list,
    int index,
  ) async {
    if (currentPlaylistBlockNotifier.value?.id != playlist.id) {
      currentPlaylistBlockNotifier.value = playlist;
      playlistIdNotifier.value = [];
      final mediaItems = list
          .map(
            (track) => MediaItem(
              id: track.id,
              album: track.speaker,
              title: track.title,
              displayDescription: track.description,
              duration: track.duration,
              artist: track.speaker,
              artUri: Uri.parse(track.thumbnail.url),
              extras: {'track': track},
            ),
          )
          .toList();
      _audioHandler.addQueueItems(mediaItems);
    }
    await Future.delayed(const Duration(milliseconds: 100));
    await _audioHandler.skipToQueueItem(index);
    _analytics.logPlaylistLoad(playlist.id, list.length, index);
  }

  void _listenToChangesInPlaylist() {
    final subscription = _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        _resetPlaylistState();
      } else {
        _updatePlaylistState(playlist);
      }
      _updateSkipButtons();
    });
    _subscriptions.add(subscription);
  }

  void _resetPlaylistState() {
    playlistIdNotifier.value = [];
  }

  void _updatePlaylistState(List<MediaItem> playlist) {
    playlistIdNotifier.value = playlist.map((item) => item.id).toList();
  }

  Stream<PlaybackState> listenPlaybackState() async* {
    await for (final playbackState in _audioHandler.playbackState) {
      yield playbackState;
    }
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    if (_isInitialized) {
      final subscription = _audioHandler.mediaItem.listen((mediaItem) {
        _updateCurrentSong(mediaItem);
        _updatePlayCount(mediaItem);
        _updateSkipButtons();
      });
      _subscriptions.add(subscription);
    }
  }

  void _updateCurrentSong(MediaItem? mediaItem) {
    currentMediaItemNotifier.value = mediaItem ?? const MediaItem(id: '', title: '');
  }

  void _updatePlayCount(MediaItem? mediaItem) {
    if (mediaItem?.id.isEmpty ?? true) return;
    if ((mediaItem!.duration?.inSeconds ?? 0) > 1) {
      _analytics.logAudioPlay(mediaItem.id, currentPlaylistBlockNotifier.value?.id);
    }
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();

  void seek(Duration position) {
    _audioHandler.seek(position);
    _analytics.logAudioSeek(
      currentMediaItemNotifier.value.id,
      progressNotifier.value.current,
      position,
      progressNotifier.value.total,
      currentPlaylistBlockNotifier.value?.id,
    );
  }

  void previous() => _audioHandler.skipToPrevious();
  void next() => _audioHandler.skipToNext();

  void skipForward() {
    Duration position;
    if (progressNotifier.value.current.inSeconds <
        (progressNotifier.value.total.inSeconds - 10)) {
      position = progressNotifier.value.current + Duration(seconds: 10);
    } else {
      position = progressNotifier.value.total;
    }
    seek(position);
  }

  void skipBackward() {
    Duration position;
    if (progressNotifier.value.current.inSeconds > 10) {
      position = progressNotifier.value.current - Duration(seconds: 10);
    } else {
      position = Duration.zero;
    }

    seek(position);
  }

  void repeat() {
    repeatButtonNotifier.nextState();
    _audioHandler.setRepeatMode(switch (repeatButtonNotifier.value) {
      RepeatState.off => AudioServiceRepeatMode.none,
      RepeatState.repeat => AudioServiceRepeatMode.all,
    });
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  void remove() {
    final lastIndex = _audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    _audioHandler.removeQueueItemAt(lastIndex);
  }

  void removeAllFromPlaylist() async {
    for (int i = 0; i < _audioHandler.queue.value.length; i++) {
      remove();
    }
  }

  void resetNotifiers() {
    progressNotifier.value = ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    );
    currentMediaItemNotifier.value = const MediaItem(id: '', title: '');
    _isInitialized = false;
  }

  void dispose() {
    if (!_isInitialized) return;
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    _audioHandler.pause();
    _audioHandler.customAction('dispose');
    resetNotifiers();
    _isInitialized = false;
  }

  void stop() {
    _audioHandler.stop();
    Get.the<AudioPanelManager>().minimize();
  }
}
