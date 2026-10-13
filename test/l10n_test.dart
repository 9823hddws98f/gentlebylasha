import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/l10n/app_localizations.dart';
import 'package:gentle/utils/inline_placeholder.dart';

Map<String, dynamic> _arb(String language) =>
    jsonDecode(File('lib/l10n/app_$language.arb').readAsStringSync()) as Map<String, dynamic>;

Set<String> _messages(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

/// Placeholder names in a message, e.g. {email}; ignores plural branches.
Set<String> _placeholders(String message) =>
    RegExp(r'\{(\w+)[,}]').allMatches(message).map((m) => m.group(1)!).toSet();

void main() {
  final en = _arb('en');
  final nl = _arb('nl');

  test('Dutch has every English message and no extra ones', () {
    expect(_messages(nl).difference(_messages(en)), isEmpty);
    expect(_messages(en).difference(_messages(nl)), isEmpty);
  });

  test('Dutch messages use the same placeholders as English', () {
    for (final key in _messages(en)) {
      expect(_placeholders(nl[key] as String), _placeholders(en[key] as String), reason: key);
    }
  });

  test('retired names never appear', () {
    for (final arb in [en, nl]) {
      for (final key in _messages(arb)) {
        expect(arb[key] as String, isNot(matches(RegExp('sleepy?tales', caseSensitive: false))),
            reason: key);
      }
    }
  });

  test('counts use the right plural form', () {
    expect(lookupAppLocalizations(const Locale('en')).sessionCount(1), '1 Session');
    expect(lookupAppLocalizations(const Locale('en')).sessionCount(4), '4 Sessions');
    expect(lookupAppLocalizations(const Locale('nl')).sessionCount(1), '1 sessie');
    expect(lookupAppLocalizations(const Locale('nl')).sessionCount(4), '4 sessies');
  });

  group('spansWithPlaceholder', () {
    const icon = WidgetSpan(child: SizedBox());

    List<Object?> texts(List<InlineSpan> spans) =>
        spans.map((s) => s is TextSpan ? s.text : s).toList();

    test('puts the span where the translation has the placeholder', () {
      final tr = lookupAppLocalizations(const Locale('en'));
      expect(texts(spansWithPlaceholder(tr.favoritesHintTracks(inlinePlaceholder), icon)),
          ['To save any audio, tap the ', icon, ' icon']);
      final nl = lookupAppLocalizations(const Locale('nl'));
      expect(texts(spansWithPlaceholder(nl.favoritesHintTracks(inlinePlaceholder), icon)),
          ['Tik op ', icon, ' om audio te bewaren']);
    });

    test('keeps a message without placeholder as it is', () {
      expect(texts(spansWithPlaceholder('Plain', icon)), ['Plain']);
    });
  });
}
