import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/domain/services/deep_linking_service.dart';

void main() {
  test('reads the type and id of a shared link', () {
    final track = SharedLink.parse(Uri.parse('https://gentle.app/shareTrack/abc123'))!;
    expect(track.type, SharedLink.track);
    expect(track.id, 'abc123');

    final playlist = SharedLink.parse(Uri.parse('https://gentle.app/sharePlaylist/p1/'))!;
    expect(playlist.type, SharedLink.playlist);
    expect(playlist.id, 'p1');
  });

  test('a URL without type and id is no shared link', () {
    expect(SharedLink.parse(Uri.parse('https://gentle.app/')), isNull);
    expect(SharedLink.parse(Uri.parse('https://gentle.app/?checkout=success')), isNull);
    expect(SharedLink.parse(Uri.parse('https://gentle.app/shareTrack')), isNull);
  });
}
