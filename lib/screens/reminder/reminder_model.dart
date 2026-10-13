import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gentle/l10n/app_localizations.dart';

import '/constants/assets.dart';

typedef ReminderText = String Function(AppLocalizations tr);

class ReminderModel {
  final Object icon;

  /// Lets the user pick weekdays; otherwise the reminder is daily.
  final bool everyday;

  /// Base of the notification ids (see ReminderService.notificationIds).
  final int reminderID;

  /// Key of the saved time/enabled settings. These are the English titles the
  /// settings were saved under before the reminders were translated; keep them.
  final String prefsKey;

  final ReminderText _heading;
  final ReminderText _description;
  final ReminderText _question;
  final ReminderText _notificationBody;

  const ReminderModel({
    required this.icon,
    this.everyday = false,
    required this.reminderID,
    required this.prefsKey,
    required ReminderText heading,
    required ReminderText description,
    required ReminderText question,
    required ReminderText notificationBody,
  })  : _heading = heading,
        _description = description,
        _question = question,
        _notificationBody = notificationBody,
        assert(icon is String || icon is IconData, 'icon must be a String or IconData');

  String heading(AppLocalizations tr) => _heading(tr);
  String description(AppLocalizations tr) => _description(tr);
  String question(AppLocalizations tr) => _question(tr);
  String notificationBody(AppLocalizations tr) => _notificationBody(tr);

  Widget buildIcon(ColorScheme colors) => icon is String
      ? SvgPicture.asset(
          icon as String,
          colorFilter: ColorFilter.mode(colors.onSurface, BlendMode.srcIn),
        )
      : Icon(icon as IconData, color: colors.onSurface);

  static const all = [
    ReminderModel(
      icon: Assets.spaBlack,
      reminderID: 11,
      prefsKey: 'Mindfulness and Meditation',
      heading: _mindfulnessHeading,
      description: _mindfulnessDescription,
      question: _mindfulnessQuestion,
      notificationBody: _mindfulnessNotification,
    ),
    ReminderModel(
      icon: Icons.alarm,
      everyday: true,
      reminderID: 12,
      prefsKey: 'Bedtime',
      heading: _bedtimeHeading,
      description: _bedtimeDescription,
      question: _bedtimeQuestion,
      notificationBody: _bedtimeNotification,
    ),
    ReminderModel(
      icon: Icons.mood,
      reminderID: 13,
      prefsKey: 'Mood check-in',
      heading: _moodHeading,
      description: _moodDescription,
      question: _moodQuestion,
      notificationBody: _moodNotification,
    ),
    ReminderModel(
      icon: Assets.localFloristBlack,
      reminderID: 14,
      // Saved under the old misspelled title; only used as a storage key.
      prefsKey: 'Grattitude check-in',
      heading: _gratitudeHeading,
      description: _gratitudeDescription,
      question: _gratitudeQuestion,
      notificationBody: _gratitudeNotification,
    ),
    ReminderModel(
      icon: Assets.menuBookBlack,
      reminderID: 15,
      prefsKey: 'Daily reflection',
      heading: _reflectionHeading,
      description: _reflectionDescription,
      question: _reflectionQuestion,
      notificationBody: _reflectionNotification,
    ),
    ReminderModel(
      icon: Icons.dark_mode,
      reminderID: 16,
      prefsKey: 'Sleep check-in',
      heading: _sleepHeading,
      description: _sleepDescription,
      question: _sleepQuestion,
      notificationBody: _sleepNotification,
    ),
  ];
}

// Top-level functions, so the reminder list can be const.
String _mindfulnessHeading(AppLocalizations tr) => tr.mindfulnessAndMeditation;
String _mindfulnessDescription(AppLocalizations tr) => tr.reminderMindfulnessDescription;
String _mindfulnessQuestion(AppLocalizations tr) => tr.reminderMindfulnessQuestion;
String _mindfulnessNotification(AppLocalizations tr) => tr.reminderMindfulnessNotification;

String _bedtimeHeading(AppLocalizations tr) => tr.bedtime;
String _bedtimeDescription(AppLocalizations tr) => tr.reminderBedtimeDescription;
String _bedtimeQuestion(AppLocalizations tr) => tr.reminderBedtimeQuestion;
String _bedtimeNotification(AppLocalizations tr) => tr.reminderBedtimeNotification;

String _moodHeading(AppLocalizations tr) => tr.moodCheckIn;
String _moodDescription(AppLocalizations tr) => tr.reminderMoodDescription;
String _moodQuestion(AppLocalizations tr) => tr.reminderMoodQuestion;
String _moodNotification(AppLocalizations tr) => tr.reminderMoodNotification;

String _gratitudeHeading(AppLocalizations tr) => tr.gratitudeCheckIn;
String _gratitudeDescription(AppLocalizations tr) => tr.reminderGratitudeDescription;
String _gratitudeQuestion(AppLocalizations tr) => tr.reminderGratitudeQuestion;
String _gratitudeNotification(AppLocalizations tr) => tr.reminderGratitudeNotification;

String _reflectionHeading(AppLocalizations tr) => tr.dailyReflection;
String _reflectionDescription(AppLocalizations tr) => tr.reminderReflectionDescription;
String _reflectionQuestion(AppLocalizations tr) => tr.reminderReflectionQuestion;
String _reflectionNotification(AppLocalizations tr) => tr.reminderReflectionNotification;

String _sleepHeading(AppLocalizations tr) => tr.sleepCheckIn;
String _sleepDescription(AppLocalizations tr) => tr.reminderSleepDescription;
String _sleepQuestion(AppLocalizations tr) => tr.reminderSleepQuestion;
String _sleepNotification(AppLocalizations tr) => tr.reminderSleepNotification;
