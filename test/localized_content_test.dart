import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/domain/models/app_page/app_page.dart';
import 'package:gentle/domain/models/block/block.dart';
import 'package:gentle/domain/models/block_item/audio_playlist.dart';
import 'package:gentle/domain/models/block_item/audio_track.dart';
import 'package:gentle/utils/localized_content.dart';

const _image = {'url': 'https://x/y.jpg', 'blurhash': 'L', 'width': 10, 'height': 10};

Map<String, dynamic> _track([Map<String, dynamic> extra = const {}]) => {
      'id': 't1',
      'title': 'Ocean',
      'writer': 'W',
      'speaker': 'S',
      'trackUrl': 'https://x/a.mp3',
      'description': 'Waves',
      'imageBackground': _image,
      'thumbnail': _image,
      'duration': 60000,
      ...extra,
    };

void main() {
  tearDown(() => ContentLanguage.code = 'en');

  group('localizedContent', () {
    test('Dutch text when the app is Dutch and it is filled in', () {
      expect(localizedContent('Ocean', 'Oceaan', 'nl'), 'Oceaan');
    });

    test('default text in English', () {
      expect(localizedContent('Ocean', 'Oceaan', 'en'), 'Ocean');
    });

    test('default text when the Dutch one is missing or blank', () {
      expect(localizedContent('Ocean', null, 'nl'), 'Ocean');
      expect(localizedContent('Ocean', '', 'nl'), 'Ocean');
      expect(localizedContent('Ocean', '  ', 'nl'), 'Ocean');
    });
  });

  group('tracks', () {
    test('documents without Dutch fields still parse', () {
      ContentLanguage.code = 'nl';
      final track = AudioTrack.fromMap(_track());
      expect(track.title, 'Ocean');
      expect(track.description, 'Waves');
      expect(track.titleNl, isNull);
    });

    test('show the Dutch fields in Dutch only', () {
      final track = AudioTrack.fromMap(_track({'titleNl': 'Oceaan', 'descriptionNl': 'Golven'}));
      expect(track.title, 'Ocean');
      ContentLanguage.code = 'nl';
      expect(track.title, 'Oceaan');
      expect(track.description, 'Golven');
    });

    test('a non-text Dutch field is ignored', () {
      ContentLanguage.code = 'nl';
      expect(AudioTrack.fromMap(_track({'titleNl': 3})).title, 'Ocean');
    });

    test('toMap keeps both languages', () {
      ContentLanguage.code = 'nl';
      final map = AudioTrack.fromMap(_track({'titleNl': 'Oceaan'})).toMap();
      expect(map['title'], 'Ocean');
      expect(map['titleNl'], 'Oceaan');
    });
  });

  test('playlists use titleNl and descriptionNl', () {
    final playlist = AudioPlaylist.fromMap({
      'id': 'p1',
      'title': 'Sleep',
      'titleNl': 'Slapen',
      'author': 'A',
      'profession': 'P',
      'description': 'Calm',
      'thumbnail': _image,
      'authorImage': _image,
      'showAudioThumbnails': true,
    });
    expect(playlist.title, 'Sleep');
    ContentLanguage.code = 'nl';
    expect(playlist.title, 'Slapen');
    expect(playlist.description, 'Calm');
  });

  test('blocks use titleNl', () {
    final block = Block.fromMap({
      'id': 'b1',
      'pageId': 'home',
      'title': 'New',
      'titleNl': 'Nieuw',
      'type': 'Normal',
      'sequence': 1,
    });
    expect(block.title, 'New');
    ContentLanguage.code = 'nl';
    expect(block.title, 'Nieuw');
    expect(block.copyWith(sequence: 2).toMap()['title'], 'New');
  });

  test('pages use nameNl and stay usable as map keys', () {
    final map = {
      'id': 'home',
      'name': 'Home',
      'nameNl': 'Thuis',
      'order': 0,
      'config': {'showItemDurations': true},
    };
    final page = AppPage.fromMap(map);
    final pages = {page: 1};
    final hash = page.hashCode;
    ContentLanguage.code = 'nl';
    expect(page.name, 'Thuis');
    expect(page.hashCode, hash);
    expect(pages[page], 1);
  });
}
