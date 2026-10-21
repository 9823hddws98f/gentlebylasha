import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/domain/models/block_item/audio_track.dart';

AudioTrack _track(int ms) {
  const image = {'url': 'u', 'blurhash': 'L', 'width': 1, 'height': 1};
  return AudioTrack.fromMap({
    'id': 't', 'title': 'T', 'writer': '', 'speaker': '', 'trackUrl': '', 'description': '',
    'thumbnail': image, 'imageBackground': image, 'duration': ms,
  });
}

void main() {
  test('cards show whole minutes, at least one', () {
    expect(_track(1860000).roundedMinutes, 31);
    expect(_track(89000).roundedMinutes, 1);
    expect(_track(150000).roundedMinutes, 3);
    expect(_track(20000).roundedMinutes, 1);
  });
  test('the player keeps minutes and seconds', () {
    expect(_track(1860000).durationString, '31:00');
  });
}
