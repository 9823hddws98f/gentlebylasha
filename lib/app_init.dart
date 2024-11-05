import 'package:audio_session/audio_session.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;

import '/domain/cubits/pages/pages_cubit.dart';
import '/firebase_options.dart';
import '/utils/get.dart';
import 'domain/services/service_locator.dart';

class AppInit {
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    _initSystemChrome();

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

  static void _initSystemChrome() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // go to immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }
}
