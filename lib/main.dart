import 'dart:io';
import 'dart:ui';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '/app_init.dart';
import '/domain/services/language_cubit.dart';
import '/screens/auth/login_screen.dart';
import '/screens/init/init_screen.dart';
import '/utils/get.dart';
import 'domain/services/interfaces/app_settings_view.dart';
import 'screens/app_container/app_container.dart';
import 'utils/app_theme.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppInit.initialize();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode && defaultTargetPlatform == TargetPlatform.macOS,
      data: DevicePreviewData(isDarkMode: true),
      builder: (context) => MyApp(),
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static const mobileWidth = 700.0;
  static const desktopContentWidth = 500.0;

  static bool get isMobile {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) return true;
    // return MediaQuery.sizeOf(this).width < mobileWidth;
    return MediaQuery.sizeOf(navigatorKey.currentContext!).width < mobileWidth;
  }

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _languageCubit = Get.the<LanguageCubit>();
  final _settings = Get.the<AppSettingsView>();

  @override
  Widget build(BuildContext context) => BlocBuilder<LanguageCubit, LanguageState>(
        bloc: _languageCubit,
        builder: (context, languageState) => ListenableBuilder(
            listenable: _settings,
            builder: (context, appSettings) => MaterialApp(
                  title: 'Gentle',
                  debugShowCheckedModeBanner: false,
                  locale: languageState.locale,
                  theme: AppTheme.buildTheme(dark: false),
                  darkTheme: AppTheme.buildTheme(dark: true),
                  scrollBehavior: const MaterialScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.touch,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  themeMode: _settings.themeMode,
                  navigatorKey: MyApp.navigatorKey,
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  initialRoute: InitScreen.routeName,
                  routes: {
                    InitScreen.routeName: (_) => InitScreen(),
                    LoginScreen.routeName: (_) => const LoginScreen(),
                    AppContainer.routeName: (_) => const AppContainer(),
                  },
                )),
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
