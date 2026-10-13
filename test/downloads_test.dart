import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/domain/models/block_item/audio_track.dart';
import 'package:gentle/domain/services/downloads_service.dart';
import 'package:gentle/utils/tx_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

AudioTrack _track(String id, {String trackUrl = 'https://example.com/a.mp3'}) {
  final image = TxImage(url: '', blurhash: '', dominantColor: null, width: 1, height: 1);
  return AudioTrack(
    id: id,
    title: 'Track $id',
    writer: '',
    speaker: '',
    trackUrl: trackUrl,
    description: '',
    imageBackground: image,
    thumbnail: image,
    hasTimer: false,
    duration: const Duration(minutes: 1),
  );
}

void main() {
  late Directory root;
  late DownloadsService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    root = await Directory.systemTemp.createTemp('downloads_test');
    service = DownloadsService(root: () async => root);
  });

  tearDown(() => root.delete(recursive: true));

  test('resolvePath keeps absolute paths and joins file names', () {
    expect(DownloadsService.resolvePath('/data/u1', 'a.mp3'), '/data/u1/a.mp3');
    expect(DownloadsService.resolvePath('/data/u1', '/old/a.mp3'), '/old/a.mp3');
  });

  test('a download belongs to the account that made it', () async {
    await service.storeTrack('u1', _track('a'), [1, 2, 3]);

    final tracks = await service.getSavedTracks('u1');
    expect(tracks.map((t) => t.id), ['a']);
    expect(tracks.single.trackUrl, '${root.path}/downloads/u1/a.mp3');
    expect(await File(tracks.single.trackUrl).readAsBytes(), [1, 2, 3]);

    expect(await service.getSavedTracks('u2'), isEmpty);
  });

  test('downloading again replaces the entry instead of adding one', () async {
    await service.storeTrack('u1', _track('a'), [1]);
    await service.storeTrack('u1', _track('a'), [2]);
    expect((await service.getSavedTracks('u1')).map((t) => t.id), ['a']);
  });

  test('removeAll deletes the files and list of one account only', () async {
    await service.storeTrack('u1', _track('a'), [1]);
    await service.storeTrack('u2', _track('b'), [2]);

    await service.removeAll('u1');

    expect(await service.getSavedTracks('u1'), isEmpty);
    expect(await Directory('${root.path}/downloads/u1').exists(), isFalse);
    expect((await service.getSavedTracks('u2')).map((t) => t.id), ['b']);
  });

  test('removeTrack deletes its file', () async {
    await service.storeTrack('u1', _track('a'), [1]);
    await service.storeTrack('u1', _track('b'), [2]);

    await service.removeTrack('u1', 'a');

    expect((await service.getSavedTracks('u1')).map((t) => t.id), ['b']);
    expect(await File('${root.path}/downloads/u1/a.mp3').exists(), isFalse);
  });

  test('a download whose file is gone is dropped', () async {
    await service.storeTrack('u1', _track('a'), [1]);
    await File('${root.path}/downloads/u1/a.mp3').delete();

    expect(await service.getSavedTracks('u1'), isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList(DownloadsService.indexKey('u1')), isEmpty);
  });

  test('downloads from before accounts go to the first account that signs in', () async {
    final legacyFile = File('${root.path}/old.mp3')..writeAsBytesSync([9]);
    SharedPreferences.setMockInitialValues({
      DownloadsService.legacyKey: [
        _track('old', trackUrl: legacyFile.path).toJson(),
        _track('gone', trackUrl: '${root.path}/missing.mp3').toJson(),
      ],
    });

    final tracks = await service.getSavedTracks('u1');
    expect(tracks.map((t) => t.id), ['old']);
    expect(tracks.single.trackUrl, legacyFile.path);
    expect(await service.getSavedTracks('u2'), isEmpty);

    // Logging out deletes them with the rest of that account's downloads.
    await service.removeAll('u1');
    expect(await legacyFile.exists(), isFalse);
  });
}
