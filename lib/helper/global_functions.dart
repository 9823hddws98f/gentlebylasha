import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '/domain/cubits/entitlement_cubit.dart';
import '/domain/cubits/favorite_playlists.dart';
import '/domain/cubits/favorite_tracks.dart';
import '/domain/models/block_item/audio_track.dart';
import '/domain/services/audio_manager.dart';
import '/domain/services/language_cubit.dart';
import '/domain/services/push_service.dart';
import '/domain/services/tracks_service.dart';
import '/helper/premium_gate.dart';
import '/screens/auth/login_screen.dart';
import '/utils/common_extensions.dart';
import '/utils/get.dart';
import '/utils/modals.dart';

void showToast(String value) {
  'showToast $value'.logDebug();
  try {
    Fluttertoast.showToast(msg: value, gravity: ToastGravity.BOTTOM, fontSize: 15);
  } on Exception catch (e) {
    'showToast error: $e'.logDebug();
  }
}

/// Signs out and clears everything tied to the account: playback, push
/// topics, premium and favorites. Every logout goes through here; [confirm]
/// asks the user first.
Future<void> logout(BuildContext context, {bool confirm = false}) async {
  if (confirm) {
    final tr = Get.the<LanguageCubit>().translation;
    final confirmed = await Modals.confirm(context, content: Text(tr.logoutConfirm));
    if (!confirmed || !context.mounted) return;
  }
  final navigator = Navigator.of(context, rootNavigator: true);

  Get.the<AudioManager>().dispose();
  // Leaving the push topics needs the network; don't hold up the logout for it.
  unawaited(PushService.instance.stop());
  await Get.the<EntitlementCubit>().reset();
  Get.the<FavoritesTracksCubit>().reset();
  Get.the<FavoritePlaylistsCubit>().reset();
  await FirebaseAuth.instance.signOut();

  navigator.pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => LoginScreen()),
    (_) => false,
  );
}

/// Opens a web page (legal, help): in an in-app browser on phones, a new tab on the web.
Future<void> openLink(Uri url) async {
  try {
    final opened = await launchUrl(
      url,
      mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.inAppBrowserView,
    );
    if (!opened) throw Exception('Could not open $url');
  } catch (e) {
    'openLink failed: $e'.logDebug();
    showToast(Get.the<LanguageCubit>().translation.linkOpenFailed);
  }
}

void pushName(BuildContext context, Widget widget) {
  FocusManager.instance.primaryFocus?.unfocus();
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => widget),
  );
}

void pushRemoveAll(BuildContext context, Widget widget) {
  Navigator.pushAndRemoveUntil(
      context, MaterialPageRoute(builder: (context) => widget), (Route<dynamic> route) => false);
}

/// Starts [track], or opens the paywall when it is premium and the user isn't.
Future<bool> playTrack(AudioTrack track) async {
  if (!requireAccess(track)) return false;
  try {
    track = (await Get.the<TracksService>().withAudioUrls([track])).first;
  } catch (_) {
    showToast(Get.the<LanguageCubit>().translation.trackLoadFailed);
    return false;
  }
  Get.the<AudioManager>().playSinglePlaylist(
    MediaItem(
      id: track.id,
      album: track.speaker,
      title: track.title,
      displayDescription: track.description,
      duration: track.duration,
      artist: track.speaker,
      displayTitle: track.title,
      displaySubtitle: track.speaker,
      artUri: Uri.parse(track.thumbnail.url),
      extras: {'track': track},
    ),
    track.id,
  );
  return true;
}
