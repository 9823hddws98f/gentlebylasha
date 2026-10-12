import 'package:audio_service/audio_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '/domain/cubits/entitlement_cubit.dart';
import '/domain/cubits/favorite_playlists.dart';
import '/domain/cubits/favorite_tracks.dart';
import '/domain/models/block_item/audio_track.dart';
import '/domain/services/audio_manager.dart';
import '/domain/services/tracks_service.dart';
import '/helper/premium_gate.dart';
import '/screens/auth/login_screen.dart';
import '/utils/common_extensions.dart';
import '/utils/get.dart';

void showToast(String value) {
  'showToast $value'.logDebug();
  try {
    Fluttertoast.showToast(msg: value, gravity: ToastGravity.BOTTOM, fontSize: 15);
  } on Exception catch (e) {
    'showToast error: $e'.logDebug();
  }
}

void logout(BuildContext context) async {
  Get.the<AudioManager>().dispose();
  Get.the<EntitlementCubit>().reset();
  Get.the<FavoritesTracksCubit>().reset();
  Get.the<FavoritePlaylistsCubit>().reset();
  final FirebaseAuth auth = FirebaseAuth.instance;
  auth.signOut();

  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => LoginScreen()),
    (_) => false,
  );
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
    showToast('This track could not be loaded.');
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
