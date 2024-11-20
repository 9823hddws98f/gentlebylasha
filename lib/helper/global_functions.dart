import 'package:audio_service/audio_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '/domain/models/block_item/audio_track.dart';
import '/domain/services/audio_manager.dart';
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
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => widget),
      (Route<dynamic> route) => false);
}

void playTrack(AudioTrack audioTrack) {
  Get.the<AudioManager>().playSinglePlaylist(
    MediaItem(
      id: audioTrack.id,
      album: audioTrack.speaker,
      title: audioTrack.title,
      displayDescription: audioTrack.description,
      artUri: Uri.parse(audioTrack.imageBackground),
      extras: {'track': audioTrack},
    ),
    audioTrack.id,
  );
}