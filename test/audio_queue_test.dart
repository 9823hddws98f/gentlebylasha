import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/domain/services/audio_manager.dart';

void main() {
  bool needsNewQueue(String? current, List<String> queued, String playlist, List<String> ids) =>
      AudioManager.needsNewQueue(
        currentPlaylistId: current,
        queuedTrackIds: queued,
        playlistId: playlist,
        trackIds: ids,
      );

  test('same playlist with the same tracks keeps the queue', () {
    expect(needsNewQueue('p1', ['a', 'b'], 'p1', ['a', 'b']), isFalse);
  });

  test('another playlist rebuilds the queue', () {
    expect(needsNewQueue('p1', ['a', 'b'], 'p2', ['a', 'b']), isTrue);
  });

  test('same playlist with other tracks rebuilds the queue (e.g. premium unlocked)', () {
    expect(needsNewQueue('p1', ['a'], 'p1', ['a', 'b']), isTrue);
    expect(needsNewQueue('p1', ['a', 'b'], 'p1', ['b', 'a']), isTrue);
  });

  test('nothing queued rebuilds the queue', () {
    expect(needsNewQueue(null, [], 'p1', ['a']), isTrue);
  });
}
