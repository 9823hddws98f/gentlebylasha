import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/domain/cubits/favorite_ids.dart';

/// Saves through [onSave]; counts the failure messages instead of showing them.
class _TestFavorites extends FavoriteIdsCubit {
  _TestFavorites(this.onSave);

  Future<void> Function(List<String> ids) onSave;
  final saved = <List<String>>[];
  var failures = 0;

  @override
  Future<void> save(List<String> ids) async {
    await onSave(ids);
    saved.add(ids);
  }

  @override
  void onSaveFailed() => failures++;
}

void main() {
  test('a change shows right away and is saved', () async {
    final cubit = _TestFavorites((_) async {});
    final adding = cubit.add('a');
    expect(cubit.state, ['a']);
    expect(await adding, isTrue);
    expect(cubit.saved, [
      ['a']
    ]);

    expect(await cubit.remove('a'), isTrue);
    expect(cubit.state, isEmpty);
    expect(cubit.failures, 0);
  });

  test('adding is undone with a message when saving fails', () async {
    final cubit = _TestFavorites((_) => Future.error(Exception('offline')));
    expect(await cubit.add('a'), isFalse);
    expect(cubit.state, isEmpty);
    expect(cubit.failures, 1);
  });

  test('removing is undone with a message when saving fails', () async {
    final cubit = _TestFavorites((_) async {});
    await cubit.add('a');
    cubit.onSave = (_) => Future.error(Exception('denied'));
    expect(await cubit.remove('a'), isFalse);
    expect(cubit.state, ['a']);
    expect(cubit.failures, 1);
  });

  test('a failed change undoes only itself', () async {
    final slow = Completer<void>();
    final cubit = _TestFavorites((ids) => ids.length == 1 ? slow.future : Future.value());
    final first = cubit.add('a');
    await cubit.add('b');
    slow.completeError(Exception('offline'));
    expect(await first, isFalse);
    expect(cubit.state, ['b']);
  });

  test('no change, nothing saved', () async {
    final cubit = _TestFavorites((_) async {});
    expect(await cubit.remove('a'), isFalse);
    await cubit.add('a');
    expect(await cubit.add('a'), isFalse);
    expect(cubit.saved, hasLength(1));
  });
}
