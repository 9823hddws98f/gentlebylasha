import 'package:audio_session/audio_session.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '/domain/cubits/favorite_playlists.dart';
import '/domain/cubits/favorite_tracks.dart';
import 'package:timezone/data/latest.dart' as tz;

import '/domain/cubits/pages/pages_cubit.dart';
import '/firebase_options.dart';
import '/utils/get.dart';
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

    //TODO: await initializeNotifications();
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
}
