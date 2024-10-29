import 'dart:io';
import 'dart:ui';

import 'package:audio_session/audio_session.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;

import '/screens/auth/login_screen.dart';
import '/utils/get.dart';
import 'domain/blocs/authentication/app_bloc.dart';
import 'domain/blocs/user/user_bloc.dart';
import 'domain/services/language_constants.dart';
import 'domain/services/service_locator.dart';
import 'firebase_options.dart';
import 'screens/app_container/app_container.dart';
import 'utils/app_theme.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  tz.initializeTimeZones();
  //TODO: await initializeNotifications();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // go to immersive mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  await FlutterTimezone.getAvailableTimezones();
  final session = await AudioSession.instance;
  await session.configure(AudioSessionConfiguration.music());
  await setupServiceLocator();

  bool isWaitingForAuth = true;
  if (FirebaseAuth.instance.currentUser == null) {
    isWaitingForAuth = false;
    FlutterNativeSplash.remove();
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode && Platform.isMacOS,
      data: DevicePreviewData(isDarkMode: true),
      builder: (context) => MyApp(isWaitingForAuth: isWaitingForAuth),
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
  final bool isWaitingForAuth;

  const MyApp({super.key, required this.isWaitingForAuth});

  static final navigatorKey = GlobalKey<NavigatorState>();

  // TODO: THIS DOESNT REFRESH CORRECTLY
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _userBloc = Get.the<UserBloc>();
  final _appBloc = Get.the<AppBloc>();
  final _translation = Get.the<TranslationService>();

  Locale? _locale;

  void setLocale(Locale locale) => setState(() => _locale = locale);

  @override
  void didChangeDependencies() {
    _translation.getLocale().then(setLocale);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: _appBloc,
        child: BlocConsumer<AppBloc, AppState>(
            listener: (context, state) async {
              if (state.status == AppStatus.loading) {
                _userBloc.add(
                  UserLoaded(
                    state.user.toAppUser(),
                    _appBloc,
                  ),
                );
              } else if (state.status == AppStatus.authenticated &&
                  widget.isWaitingForAuth) {
                await initServices();
                FlutterNativeSplash.remove();
              }
            },
            builder: (context, state) => state.status == AppStatus.loading
                ? const SizedBox(child: CircularProgressIndicator())
                : MaterialApp(
                    title: 'Gentle',
                    debugShowCheckedModeBanner: false,
                    locale: _locale,
                    theme: AppTheme.buildTheme(dark: false),
                    darkTheme: AppTheme.buildTheme(dark: true),
                    scrollBehavior: const ScrollBehavior().copyWith(
                      dragDevices: {
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.touch,
                        PointerDeviceKind.trackpad,
                      },
                    ),
                    navigatorKey: MyApp.navigatorKey,
                    localizationsDelegates: AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    initialRoute: widget.isWaitingForAuth
                        ? AppContainer.routeName
                        : LoginScreen.routeName,
                    routes: {
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
