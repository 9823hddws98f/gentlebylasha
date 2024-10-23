import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:sleeptales/screens/auth/login_screen.dart';
import 'package:timezone/data/latest.dart' as tz;

import '/screens/home_screen.dart';
import '/screens/splash_screen.dart';
import '/services/service_locator.dart';
import '/utils/route_constant.dart';
import 'firebase_options.dart';
import 'language_constants.dart';
import 'utils/app_theme.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  //TODO: await initializeNotifications();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await FlutterTimezone.getAvailableTimezones();
  final session = await AudioSession.instance;
  await session.configure(AudioSessionConfiguration.music());
  await setupServiceLocator();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode && Platform.isMacOS,
      data: DevicePreviewData(
        isDarkMode: true,
      ),
      builder: (context) => const MyApp(),
    ),
  );
}

void setupFirebaseMessaging() {
  // TODO: setup firebase messaging
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Received message: ${message.notification?.title}');
    displayNotification(message);
  });
}

void displayNotification(RemoteMessage message) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'sleeptalespush112',
    'New Tracks',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale) => setState(() => _locale = locale);

  @override
  void didChangeDependencies() {
    getLocale().then(setLocale);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Gentle',
        debugShowCheckedModeBanner: false,
        locale: _locale,
        theme: AppTheme.buildTheme(dark: false),
        darkTheme: AppTheme.buildTheme(dark: true),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: splashPath,
        routes: {
          splashPath: (context) => const SplashScreen(),
          loginPath: (context) => const LoginScreen(),
          dashboard: (context) => const HomeScreen(),
        },
      );
}

// Define a method to initialize the plugin and request permission to send notifications
Future<void> initializeNotifications() async {
  await requestNotificationPermission();
  const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  final initializationSettingsDarwin = DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
    //TODO:  onDidReceiveLocalNotification:
  );
  final initializationSettings = InitializationSettings(
    android: androidInitSettings,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> requestNotificationPermission() async {
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        AndroidNotificationChannel(
          'daily_reminder',
          'Daily Reminder',
          importance: Importance.max,
          vibrationPattern: Int64List.fromList([0, 500, 500, 1000]),
        ),
      );
}
