import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;

import '/domain/cubits/entitlement_cubit.dart';
import '/domain/cubits/in_app_purchases/iap_cubit.dart';
import '/domain/cubits/favorite_playlists.dart';
import '/domain/cubits/favorite_tracks.dart';
import '/domain/cubits/pages/pages_cubit.dart';
import '/domain/services/app_check.dart';
import '/domain/services/push_service.dart';
import '/domain/services/reminder_service.dart';
import '/firebase_options.dart';
import '/utils/get.dart';
import 'domain/services/app_settings.dart';
import 'domain/services/service_locator.dart';

class AppInit {
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    await _initializeFirebase();

    _setSystemChrome();

    await FlutterTimezone.getAvailableTimezones();

    /// Initialize audio session
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    /// Initialize service locator
    await setupServiceLocator();

    await Get.the<AppSettings>().initialize();
    await Get.the<ReminderService>().initialize();
  }

  /// Local development against the Firebase emulators:
  /// `--dart-define=FIREBASE_EMULATORS=true` (optionally `EMULATOR_HOST`,
  /// e.g. 10.0.2.2 on an Android emulator). Uses the demo project
  /// `demo-gentle`, so nothing can reach production. On web a reload loses the
  /// session (Firebase restores it before the emulator is connected): sign in again.
  static const useEmulators = bool.fromEnvironment('FIREBASE_EMULATORS');
  static const _emulatorHost = String.fromEnvironment('EMULATOR_HOST', defaultValue: '127.0.0.1');

  static Future<void> _initializeFirebase() async {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (!useEmulators) {
      await Firebase.initializeApp(options: options);
      // Off unless built with APP_CHECK=true; never in emulator mode.
      await AppCheckSetup.activate();
      return;
    }
    // No measurementId: Analytics can't run against a demo project.
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: options.apiKey,
        appId: options.appId,
        messagingSenderId: options.messagingSenderId,
        projectId: 'demo-gentle',
        authDomain: options.authDomain,
        storageBucket: 'demo-gentle.appspot.com',
        iosBundleId: options.iosBundleId,
      ),
    );
    await FirebaseAuth.instance.useAuthEmulator(_emulatorHost, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(_emulatorHost, 8080);
    await FirebaseStorage.instance.useStorageEmulator(_emulatorHost, 9199);
    FirebaseFunctions.instanceFor(region: 'us-central1').useFunctionsEmulator(_emulatorHost, 5001);
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
    // Content is only readable for signed-in users, so pages load after auth.
    await Get.the<PagesCubit>().init();
    await Get.the<EntitlementCubit>().init();
    if (!kIsWeb) Get.the<IAPCubit>().start();
    unawaited(PushService.instance.start());
    await Get.the<FavoritesTracksCubit>().init();
    await Get.the<FavoritePlaylistsCubit>().init();
  }
}
