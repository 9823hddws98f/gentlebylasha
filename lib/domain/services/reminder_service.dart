import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '/helper/global_functions.dart';
import '/utils/common_extensions.dart';

class ReminderService {
  static const String _channelId = 'daily_reminder';
  static const String _channelName = 'Daily Reminder';
  static const String _selectedDaysKey = 'selectedDays';

  ReminderService._();
  static final instance = ReminderService._();

  late final FlutterLocalNotificationsPlugin _notificationsPlugin;
  late final SharedPreferences _prefs;

  Future<void> initialize() async {
    if (kIsWeb || Platform.isMacOS) return;
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    _prefs = await SharedPreferences.getInstance();
    await _initializeTimeZone();
    await _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    await _notificationsPlugin.initialize(
      InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _requestPermissions();
    await _setupNotificationChannels();
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
      showToast('Failed to request notification permissions');
      return false;
    }
  }

  Future<void> _setupNotificationChannels() async => await _notificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        AndroidNotificationChannel(
          _channelId,
          _channelName,
          importance: Importance.max,
          vibrationPattern: Int64List.fromList([0, 500, 500, 1000]),
        ),
      );

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
        showToast('Please enable notifications in phone settings');
        return false;
      }
    } else {
      return true;
    }
  }

  /// Sets a daily reminder notification that repeats at the specified time each day.
  ///
  /// Parameters:
  /// - [id]: Unique identifier for the notification
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
        id,
        title,
        description,
        scheduledDate,
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
  /// - [id]: Unique identifier for the notification
  /// - [title]: Title text shown in the notification
  /// - [description]: Body text shown in the notification
  /// - [time]: Time of day when the notification should be shown
  /// - [days]: List of booleans indicating which days of the week the reminder should be shown
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

    final now = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        final adjustedDay = (i + 1) % 7;
        final scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + (adjustedDay - now.weekday) % 7,
          time.hour,
          time.minute,
        );

        await _notificationsPlugin.zonedSchedule(
          id + i,
          title,
          description,
          scheduledDate,
          _notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
      _channelName,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      vibrationPattern: Int64List.fromList([0, 500, 500, 1000]),
    );

    final iosDetails = DarwinNotificationDetails();
    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id);
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
