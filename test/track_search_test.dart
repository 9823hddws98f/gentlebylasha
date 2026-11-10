import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/domain/services/tracks_service.dart';

void main() {
  const track = {
    'title': 'Under the stars',
    'titleNl': 'Onder de sterren',
    'speaker': 'Anna de Vries',
    'writer': 'Gentle',
  };

  group('TracksService.matchesSearch', () {
    test('finds the English title', () {
      expect(TracksService.matchesSearch(track, 'stars'), isTrue);
    });

    test('finds the Dutch title', () {
      expect(TracksService.matchesSearch(track, 'sterren'), isTrue);
    });

    test('finds the speaker and the writer', () {
      expect(TracksService.matchesSearch(track, 'anna'), isTrue);
      expect(TracksService.matchesSearch(track, 'gentle'), isTrue);
    });

    test('ignores tracks without a match or without the field', () {
      expect(TracksService.matchesSearch(track, 'regen'), isFalse);
      expect(TracksService.matchesSearch(const {'title': 'Rain'}, 'sterren'), isFalse);
    });
  });
}
