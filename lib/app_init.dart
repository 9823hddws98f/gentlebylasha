import 'package:audio_session/audio_session.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;

import '/domain/cubits/favorite_playlists.dart';
import '/domain/cubits/favorite_tracks.dart';
import '/domain/cubits/pages/pages_cubit.dart';
import '/domain/services/reminder_service.dart';
import '/firebase_options.dart';
import '/utils/get.dart';
import 'domain/services/app_settings.dart';
import 'domain/services/service_locator.dart';

class AppInit {
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    _setSystemChrome();

    await FlutterTimezone.getAvailableTimezones();

    /// Initialize audio session
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    /// Initialize service locator
    await setupServiceLocator();

    /// Initialize App Pages
    await Get.the<PagesCubit>().init();
    await Get.the<AppSettings>().initialize();
    await Get.the<ReminderService>().initialize();
  }

  static void _setSystemChrome() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemStatusBarContrastEnforced: false,
    ));

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
  }

  static Future<void> initUserBasedServices() async {
    await Get.the<FavoritesTracksCubit>().init();
    await Get.the<FavoritePlaylistsCubit>().init();
  }

  void setupFirebaseMessaging() {
    // TODO: setup firebase messaging
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received message: ${message.notification?.title}');
      displayNotification(message);
    });
  }

  void displayNotification(RemoteMessage message) async {
    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await localNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'sleeptalespush112',
      'New Tracks',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await localNotificationsPlugin.show(
      0,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      platformChannelSpecifics,
    );
  }

  void subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }
}
