import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '/domain/cubits/entitlement_cubit.dart';
import '/helper/global_functions.dart';
import '/utils/get.dart';
import 'language_cubit.dart';

/// Push messages sent from the admin. Each device is subscribed to its
/// language (lang_en/lang_nl) and to premium or free; the admin targets
/// those topics (functions/src/push.ts). On the web the browser can't join
/// topics itself: its token goes to syncWebPushTopics, and only after the
/// user turned notifications on in the settings.
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  /// Named in the app language; Android shows it in the app's notification
  /// settings. Created again (same id) on start, which renames it.
  static AndroidNotificationChannel get _channel {
    final tr = Get.the<LanguageCubit>().translation;
    return AndroidNotificationChannel(
      'gentle_news',
      tr.newsChannelName,
      description: tr.newsChannelDescription,
      importance: Importance.high,
    );
  }

  /// Firebase console → Cloud Messaging → Web configuration → key pair.
  /// Without it (--dart-define=WEB_PUSH_VAPID_KEY=…) the web has no push.
  static const _vapidKey = String.fromEnvironment('WEB_PUSH_VAPID_KEY');
  static bool get webPushAvailable => kIsWeb && _vapidKey.isNotEmpty;

  /// The web app's FCM token while web push is on.
  String? _webToken;
  bool get webPushOn => _webToken != null;

  final _messaging = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();
  final _subscriptions = <StreamSubscription>[];

  /// Syncs run one after the other, so a quick language switch can't end
  /// with the topics of the older state.
  Future<void> _syncQueue = Future.value();

  /// Every topic the app uses; a signed-out device leaves them all.
  static const allTopics = ['lang_en', 'lang_nl', 'premium', 'free'];

  /// Which topics a device should be in and which it should leave. Mirrors
  /// topicsFor() in functions/src/push.ts.
  static ({List<String> subscribe, List<String> unsubscribe}) topicsFor(
    String language,
    bool premium,
  ) {
    final lang = language == 'nl' ? 'nl' : 'en';
    final other = lang == 'en' ? 'nl' : 'en';
    return (
      subscribe: ['lang_$lang', premium ? 'premium' : 'free'],
      unsubscribe: ['lang_$other', premium ? 'free' : 'premium'],
    );
  }

  /// Set synchronously so overlapping start() calls can't both add listeners.
  bool _running = false;

  Future<void> start() async {
    if (_running) return;
    if (kIsWeb) {
      // Never prompt on page load; only resume when the user allowed it before.
      if (!webPushAvailable) return;
      final settings = await _messaging.getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) await _startWeb();
      return;
    }
    _running = true;

    final settings = await _messaging.requestPermission();
    // stop() may have run while the permission prompt was open.
    if (!_running || settings.authorizationStatus == AuthorizationStatus.denied) return;

    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
    // iOS shows notifications itself while the app is open.
    await _messaging.setForegroundNotificationPresentationOptions(alert: true, sound: true);

    // EntitlementCubit also emits when premium expires (timer at expiresAt).
    _subscriptions
      ..add(FirebaseMessaging.onMessage.listen(_showOnAndroid))
      ..add(Get.the<EntitlementCubit>().stream.listen((_) => _syncTopics()))
      ..add(Get.the<LanguageCubit>().stream.listen((_) => _syncTopics()))
      // Topic calls fail until iOS has an APNs token; retry when a token arrives.
      ..add(_messaging.onTokenRefresh.listen((_) => _syncTopics()));
    await _waitForApnsToken();
    await _syncTopics();
  }

  /// Turns web push on from a tap in the settings (browsers want a user
  /// gesture for the permission prompt). Returns whether it is on now.
  Future<bool> enableWebPush() async {
    if (!webPushAvailable) return false;
    if (webPushOn) return true;
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) return false;
    await _startWeb();
    return webPushOn;
  }

  Future<void> _startWeb() async {
    _running = true;
    try {
      _webToken = await _messaging.getToken(vapidKey: _vapidKey);
    } catch (e) {
      debugPrint('Web push token failed: $e');
    }
    if (!_running || _webToken == null) {
      _running = false;
      return;
    }
    _subscriptions
      // A focused tab gets no system notification; show it quietly in the app.
      ..add(FirebaseMessaging.onMessage.listen((m) {
        final n = m.notification;
        if (n != null) showToast([n.title, n.body].whereType<String>().join('\n'));
      }))
      ..add(Get.the<EntitlementCubit>().stream.listen((_) => _syncTopics()))
      ..add(Get.the<LanguageCubit>().stream.listen((_) => _syncTopics()))
      ..add(_messaging.onTokenRefresh.listen((token) {
        _webToken = token;
        _syncTopics();
      }));
    await _syncTopics();
  }

  /// On iOS, subscribing to topics throws until the APNs token is known.
  Future<void> _waitForApnsToken() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    for (var i = 0; i < 10 && _running; i++) {
      if (await _messaging.getAPNSToken() != null) return;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// Leaves all topics, so a signed-out device gets no targeted pushes.
  Future<void> stop() async {
    _running = false;
    for (final s in _subscriptions) {
      await s.cancel();
    }
    _subscriptions.clear();
    if (kIsWeb) {
      // A deleted token gets no pushes at all, whatever topics it was in.
      if (_webToken != null) {
        _webToken = null;
        await _messaging.deleteToken().catchError((Object e) => debugPrint('Deleting web push token failed: $e'));
      }
      return;
    }
    await (_syncQueue = _syncQueue.then((_) async {
      for (final topic in allTopics) {
        try {
          await _messaging.unsubscribeFromTopic(topic);
        } catch (e) {
          debugPrint('Leaving push topic $topic failed: $e');
        }
      }
    }));
  }

  /// Joins the topics for the current language and premium state and leaves
  /// the others. Always sends both, whatever the device was in before (an
  /// earlier session, an app update or a failed call may have left it in the
  /// wrong ones); subscribing twice is harmless.
  Future<void> _syncTopics() => _syncQueue = _syncQueue.then((_) async {
        if (!_running) return;
        final topics = topicsFor(
          Get.the<LanguageCubit>().languageCode,
          Get.the<EntitlementCubit>().state.isPremium,
        );
        try {
          if (kIsWeb) {
            final token = _webToken;
            if (token == null) return;
            // The server decides premium or free itself.
            await FirebaseFunctions.instanceFor(region: 'us-central1')
                .httpsCallable('syncWebPushTopics')
                .call({'token': token, 'language': Get.the<LanguageCubit>().languageCode});
            return;
          }
          for (final topic in topics.subscribe) {
            await _messaging.subscribeToTopic(topic);
          }
          for (final topic in topics.unsubscribe) {
            await _messaging.unsubscribeFromTopic(topic);
          }
        } catch (e) {
          debugPrint('Push topic sync failed: $e');
        }
      });

  /// Android doesn't show notifications for messages received in the foreground.
  void _showOnAndroid(RemoteMessage message) {
    final n = message.notification;
    if (n == null || defaultTargetPlatform != TargetPlatform.android) return;
    final channel = _channel;
    _local.show(
      message.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(channel.id, channel.name,
            channelDescription: channel.description,
            importance: Importance.high,
            icon: '@drawable/ic_notification'),
      ),
    );
  }
}
