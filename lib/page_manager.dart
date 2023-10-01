import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sleeptales/utils/firestore_helper.dart';
import 'models/audiofile_model.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'package:audio_service/audio_service.dart';
import 'notifiers/repeat_notifier.dart';
import 'services/playlist_repository.dart';
import 'services/service_locator.dart';

class PageManager {
  final currentSongTitleNotifier = ValueNotifier<String>('---');
  final currentMediaItemNotifier = ValueNotifier<MediaItem>(MediaItem(id: "",title: ""));
  final playlistNotifier = ValueNotifier<List<String>>([]);
  final playlistIdNotifier = ValueNotifier<List<String>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  final _audioHandler = getIt<AudioHandler>();
  bool isBufferingDone = true;
  bool check = true;


  void init() async {
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
    _listenToPlaying();
  }

  Future<void> playSinglePlaylist(MediaItem mediaItem,String trackId) async {
    isBufferingDone = false;
    if(currentMediaItemNotifier.value.id != trackId){
     playlistNotifier.value = [];
     playlistIdNotifier.value = [];
      _audioHandler.addQueueItem(mediaItem);
    }
  }

  Future<void> loadPlaylist(List<AudioTrack> list,int index) async {
    isBufferingDone = false;
    if(currentMediaItemNotifier.value.id != list[index].trackId){
      playlistNotifier.value = [];
      playlistIdNotifier.value = [];
      final mediaItems = list
          .map((song) =>
          MediaItem(
            id: song.trackId ?? '',
            album: song.speaker ?? '',
            title: song.title ?? '',
            displayDescription: song.description,
            artUri: Uri.parse(song.imageBackground ?? ''),
            extras: {
              'url': song.trackUrl,
              'id': song.trackId,
              'categories': song.categories[0].categoryName
            },
          ))
          .toList();
      _audioHandler.addQueueItems(mediaItems);
      Future.delayed(Duration(milliseconds: 200), () { // <-- Delay here
        _audioHandler.skipToQueueItem(index);
      });

    }

  }

  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        playlistNotifier.value = [];
        playlistIdNotifier.value = [];
        currentSongTitleNotifier.value = '';
      } else {
        final newList = playlist.map((item) => item.title).toList();
        final newIdList = playlist.map((item) => item.id).toList();
        playlistNotifier.value = newList;
        playlistIdNotifier.value = newIdList;
      }
      _updateSkipButtons();
    });
  }

  bool _listenToPlaying(){
    bool isPlaying = false;
    _audioHandler.playbackState.listen((playbackState) {
      isPlaying = playbackState.playing;

    });
        return isPlaying;
  }


  void stopTrackAfter(Duration duration){
    Timer(duration, () {
     pause();

    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
        if (!isBufferingDone) {
          if(processingState == AudioProcessingState.ready) {
            play();
            isBufferingDone = true;
          }
        }
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;

      }  else{
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
        isBufferingDone = false;
      }
    });
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
    if(check) {
      _audioHandler.mediaItem.listen((mediaItem) {
        currentSongTitleNotifier.value = mediaItem?.title ?? '';
        currentMediaItemNotifier.value =
            mediaItem ?? MediaItem(id: "", title: "");
        if (mediaItem != null) {
          if (mediaItem.id != "") {
            addToRecentlyPlayed(mediaItem.id);
            incrementPlayCount(mediaItem.id);
          }
        }
        _updateSkipButtons();
      });
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

  void seek(Duration position) => _audioHandler.seek(position);

  void previous() => _audioHandler.skipToPrevious();
  void next() => _audioHandler.skipToNext();

  void skipForward(){
    Duration position;
    if(progressNotifier.value.current.inSeconds < (progressNotifier.value.total.inSeconds - 10)) {
      position = progressNotifier.value.current + Duration(seconds: 10);
    }else{
      position  =progressNotifier.value.total;
    }
    seek(position);
  }

  void skipBackward(){
    Duration position;
    if(progressNotifier.value.current.inSeconds > 10) {
      position = progressNotifier.value.current - Duration(seconds: 10);
    }else{
      position = Duration.zero;
    }

    seek(position);
  }

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
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

  Future<void> add() async {
    final songRepository = getIt<PlaylistRepository>();
    final song = await songRepository.fetchAnotherSong();
    final mediaItem = MediaItem(
      id: song['id'] ?? '',
      album: song['album'] ?? '',
      title: song['title'] ?? '',
      extras: {'url': song['url']},
    );
    _audioHandler.addQueueItem(mediaItem);
  }

  void remove() {
    final lastIndex = _audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    _audioHandler.removeQueueItemAt(lastIndex);
  }

  void removeAllFromPlaylist() async{
    for(int i =0;i<_audioHandler.queue.value.length;i++){
      remove();
    }

  }


  void resetNotifiers() {
    currentSongTitleNotifier.value = '---';
    progressNotifier.value = ProgressBarState(current: Duration.zero, buffered: Duration.zero, total: Duration.zero);
    playlistNotifier.value = [];
    currentMediaItemNotifier.value = MediaItem(id: "", title: "");
    check = false;
  }


  void dispose() {
    _audioHandler.pause();
    _audioHandler.customAction('dispose');
    resetNotifiers();
  }

  void stop() {
    _audioHandler.stop();
  }
}