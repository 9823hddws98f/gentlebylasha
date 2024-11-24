import 'dart:io';
import 'dart:ui';

import 'package:device_preview/device_preview.dart';
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

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
                  routes: {
                    LoginScreen.routeName: (_) => const LoginScreen(),
                    AppContainer.routeName: (_) => const AppContainer(),
                  },
                  onGenerateInitialRoutes: (initialRoute) {
                    return [
                      MaterialPageRoute(builder: (_) => InitScreen()),
                    ];
                  },
                )),
      );
}
