import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:gentle/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '/helper/global_functions.dart';
import '/screens/reminder/reminder_model.dart';
import '/utils/common_extensions.dart';
import '/utils/get.dart';
import 'language_cubit.dart';

class ReminderService {
  static const String _channelId = 'daily_reminder';
  static const String _selectedDaysKey = 'selectedDays';

  /// 2: notification ids from [notificationId]. 1 (before): reminder id + day
  /// index, which made reminders overwrite each other.
  static const _idSchemeKey = 'reminderIdScheme';
  static const _idScheme = 2;

  /// Language of the scheduled notification texts.
  static const _languageKey = 'reminderLanguage';

  ReminderService._();
  static final instance = ReminderService._();

  late final FlutterLocalNotificationsPlugin _notificationsPlugin;
  late final SharedPreferences _prefs;

  /// Notification id of one slot of a reminder: slot 0 for a daily reminder,
  /// 1–7 for a weekday (DateTime.monday … DateTime.sunday). Reminder ids are
  /// 11–16, so reminders never share an id.
  static int notificationId(int reminderId, int slot) => reminderId * 10 + slot;

  /// Every notification id a reminder can use.
  static List<int> notificationIds(int reminderId) =>
      [for (var slot = 0; slot <= 7; slot++) notificationId(reminderId, slot)];

  Future<void> initialize() async {
    if (kIsWeb || Platform.isMacOS) return;
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    _prefs = await SharedPreferences.getInstance();
    await _initializeTimeZone();
    final languageCode = await LanguageCubit.loadLanguageCode();
    await _initializeNotifications(lookupAppLocalizations(Locale(languageCode)));
    await _migrateIds();
    await _syncLanguage(languageCode);
    // Scheduled texts follow the app language.
    Get.the<LanguageCubit>()
        .stream
        .listen((state) => _syncLanguage(state.locale.languageCode));
  }

  /// Old installs scheduled reminders under ids that overlapped; cancel those
  /// once. [_syncLanguage] then schedules the enabled reminders again.
  Future<void> _migrateIds() async {
    if ((_prefs.getInt(_idSchemeKey) ?? 1) >= _idScheme) return;
    try {
      for (var id = 11; id <= 22; id++) {
        await _notificationsPlugin.cancel(id);
      }
      await _prefs.remove(_languageKey);
      await _prefs.setInt(_idSchemeKey, _idScheme);
    } catch (e) {
      'Migrating reminders failed: $e'.logDebug();
    }
  }

  Future<void> _syncLanguage(String languageCode) async {
    if (_prefs.getString(_languageKey) == languageCode) return;
    final tr = lookupAppLocalizations(Locale(languageCode));
    await _setupNotificationChannels(tr);
    for (final reminder in ReminderModel.all) {
      if (!await isReminderEnabled(reminder.prefsKey)) continue;
      final time = await getTimeOfDay(reminder.prefsKey);
      try {
        if (reminder.everyday) {
          await _scheduleWeekly(
            reminder.reminderID,
            reminder.heading(tr),
            reminder.notificationBody(tr),
            time,
            await getSelectedDays(),
          );
        } else {
          await _scheduleDaily(
            reminder.reminderID,
            reminder.heading(tr),
            reminder.notificationBody(tr),
            time,
          );
        }
      } catch (e) {
        'Rescheduling reminder ${reminder.reminderID} failed: $e'.logDebug();
      }
    }
    await _prefs.setString(_languageKey, languageCode);
  }

  Future<void> _initializeNotifications(AppLocalizations tr) async {
    // Small monochrome icon in the Android status bar.
    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    final iosSettings = DarwinInitializationSettings(
      // Asked when the user turns a reminder on, not at first launch.
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    await _notificationsPlugin.initialize(
      InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _setupNotificationChannels(tr);
  }

  Future<bool> _requestPermissions() async {
    try {
      if (Platform.isIOS) {
        final iosPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        return await iosPlugin?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      } else if (Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        return await androidPlugin?.requestNotificationsPermission() ?? false;
      }
      return false;
    } catch (e) {
      'Error requesting permissions: $e'.logDebug();
      showToast(Get.the<LanguageCubit>().translation.notificationPermissionFailed);
      return false;
    }
  }

  /// Creates the channel, or renames it (same id) when the language changes;
  /// Android shows the name in the app's notification settings.
  Future<void> _setupNotificationChannels(AppLocalizations tr) async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          AndroidNotificationChannel(
            _channelId,
            tr.reminderChannelName,
            importance: Importance.max,
            vibrationPattern: Int64List.fromList([0, 500, 500, 1000]),
          ),
        );
  }

  /// Checks if notifications are permitted on the device
  Future<bool> _areNotificationsEnabled() async {
    final androidEnabled = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        false;

    final iosEnabled = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true) ??
        false;

    // Request permissions if not enabled
    if (!androidEnabled && !iosEnabled) {
      if (await _requestPermissions()) {
        return true;
      } else {
        showToast(Get.the<LanguageCubit>().translation.enableNotificationsInSettings);
        return false;
      }
    } else {
      return true;
    }
  }

  /// Sets a daily reminder notification that repeats at the specified time each day.
  ///
  /// Parameters:
  /// - [id]: The reminder (ReminderModel.reminderID); see [notificationId]
  /// - [title]: Title text shown in the notification
  /// - [description]: Body text shown in the notification
  /// - [time]: Time of day when the notification should be shown
  Future<void> setDailyReminder({
    required int id,
    required String title,
    required String description,
    required TimeOfDay time,
  }) async {
    if (!await _areNotificationsEnabled()) {
      throw Exception('Notifications are not enabled');
    }
    await _scheduleDaily(id, title, description, time);
  }

  Future<void> _scheduleDaily(int id, String title, String description, TimeOfDay time) async {
    await cancelReminder(id);
    try {
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      await _notificationsPlugin.zonedSchedule(
        notificationId(id, 0),
        title,
        description,
        scheduledDate,
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      'Error scheduling daily reminder: $e'.logDebug();
      rethrow;
    }
  }

  /// Sets a weekly reminder notification that repeats at the specified time each week on the selected days.
  ///
  /// Parameters:
  /// - [id]: The reminder (ReminderModel.reminderID); see [notificationId]
  /// - [title]: Title text shown in the notification
  /// - [description]: Body text shown in the notification
  /// - [time]: Time of day when the notification should be shown
  /// - [days]: Which weekdays, Monday (index 0) to Sunday (index 6)
  Future<void> setWeeklyReminder({
    required int id,
    required String title,
    required String description,
    required TimeOfDay time,
    required List<bool> days,
  }) async {
    if (!await _areNotificationsEnabled()) {
      throw Exception('Notifications are not enabled');
    }
    await _scheduleWeekly(id, title, description, time, days);
  }

  /// [days] runs Monday (index 0) to Sunday (index 6).
  Future<void> _scheduleWeekly(
    int id,
    String title,
    String description,
    TimeOfDay time,
    List<bool> days,
  ) async {
    // Also removes days that were switched off.
    await cancelReminder(id);
    final now = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < days.length && i < 7; i++) {
      if (days[i]) {
        final weekday = i + 1; // DateTime.monday … DateTime.sunday
        final scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + (weekday - now.weekday) % 7,
          time.hour,
          time.minute,
        );

        await _notificationsPlugin.zonedSchedule(
          notificationId(id, weekday),
          title,
          description,
          scheduledDate,
          _notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  NotificationDetails get _notificationDetails {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      Get.the<LanguageCubit>().translation.reminderChannelName,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      vibrationPattern: Int64List.fromList([0, 500, 500, 1000]),
    );

    final iosDetails = DarwinNotificationDetails();
    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// Cancels every notification of reminder [id] (daily and all weekdays).
  Future<void> cancelReminder(int id) async {
    for (final notification in notificationIds(id)) {
      await _notificationsPlugin.cancel(notification);
    }
  }

  // Preferences Management
  Future<void> saveTimeOfDay(String id, TimeOfDay time) async {
    await _prefs.setInt('${id}hour', time.hour);
    await _prefs.setInt('${id}minute', time.minute);
  }

  Future<TimeOfDay> getTimeOfDay(String id) async {
    final hour = _prefs.getInt('${id}hour');
    final minute = _prefs.getInt('${id}minute');
    return hour != null && minute != null
        ? TimeOfDay(hour: hour, minute: minute)
        : TimeOfDay.now();
  }

  Future<void> saveDaysOfWeek(List<bool> days) async {
    await _prefs.setStringList(
      _selectedDaysKey,
      days.map((day) => day.toString()).toList(),
    );
  }

  Future<List<bool>> getSelectedDays() async {
    final days = _prefs.getStringList(_selectedDaysKey) ?? List.filled(7, 'false');
    return days.map((day) => day == 'true').toList();
  }

  Future<void> saveReminderEnabled(String id, bool value) async {
    if (value) await _requestPermissions();
    await _prefs.setBool(id, value);
  }

  Future<bool> isReminderEnabled(String id) async {
    return _prefs.getBool(id) ?? false;
  }

  Future<void> _initializeTimeZone() async {
    final timeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone));
  }

  Future<void> dispose() async {
    await _notificationsPlugin.cancelAll();
  }
}
