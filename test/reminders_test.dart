import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/domain/services/reminder_service.dart';
import 'package:gentle/l10n/app_localizations.dart';
import 'package:gentle/screens/reminder/reminder_model.dart';

void main() {
  test('reminders never share a notification id', () {
    final ids = [
      for (final reminder in ReminderModel.all)
        ...ReminderService.notificationIds(reminder.reminderID),
    ];
    expect(ids.toSet().length, ids.length);
  });

  test('ids per slot', () {
    expect(ReminderService.notificationId(12, 0), 120);
    expect(ReminderService.notificationId(12, DateTime.sunday), 127);
    expect(ReminderService.notificationIds(12), [120, 121, 122, 123, 124, 125, 126, 127]);
  });

  test('new ids stay clear of the old ones (11–22)', () {
    for (final reminder in ReminderModel.all) {
      for (final id in ReminderService.notificationIds(reminder.reminderID)) {
        expect(id, greaterThan(22));
      }
    }
  });

  test('saved settings keep their old keys', () {
    expect(ReminderModel.all.map((r) => r.prefsKey).toSet().length, ReminderModel.all.length);
  });

  for (final language in ['en', 'nl']) {
    test('every reminder has copy in $language', () {
      final tr = lookupAppLocalizations(Locale(language));
      for (final r in ReminderModel.all) {
        for (final text in [
          r.heading(tr),
          r.description(tr),
          r.question(tr),
          r.notificationBody(tr)
        ]) {
          expect(text.trim(), isNotEmpty);
          expect(text, isNot(contains('required from client')));
          expect(text.toLowerCase(), isNot(contains('grattitude')));
        }
      }
    });
  }
}
