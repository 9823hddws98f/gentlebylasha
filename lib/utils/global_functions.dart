import 'package:audio_service/audio_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleeptales/utils/get.dart';

import '/domain/models/block_item/audio_track.dart';
import '/domain/services/service_locator.dart';
import '/page_manager.dart';
import '/screens/auth/login_screen.dart';
import '/utils/common_extensions.dart';

void showToast(String value) {
  'showToast $value'.logDebug();
  try {
    Fluttertoast.showToast(msg: value, gravity: ToastGravity.BOTTOM, fontSize: 15);
  } on Exception catch (e) {
    'showToast error: $e'.logDebug();
  }
}

ValueNotifier<String> valueNotifierName = ValueNotifier("");

Future<void> saveTimeOfDay(String id, TimeOfDay time) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('${id}hour', time.hour);
  await prefs.setInt('${id}minute', time.minute);
}

Future<TimeOfDay> getTimeOfDay(String id) async {
  final prefs = await SharedPreferences.getInstance();
  final hour = prefs.getInt('${id}hour');
  final minute = prefs.getInt('${id}minute');
  if (hour == null || minute == null) {
    return TimeOfDay.now();
  }
  return TimeOfDay(hour: hour, minute: minute);
}

Future<void> saveDaysOfWeek(List<bool> list) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList('selectedDays', list.map((day) => day.toString()).toList());
}

Future<List<bool>> getSelectedDays() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> selectedDaysStrList =
      prefs.getStringList('selectedDays') ?? List.filled(7, 'false');
  List<bool> selectedDays = selectedDaysStrList.map((day) => day == 'true').toList();
  return selectedDays;
}

Future<String> saveReminderValue(String id, bool value) async {
  final Future<SharedPreferences> prefs0 = SharedPreferences.getInstance();
  final SharedPreferences prefs = await prefs0;
  prefs.setBool(id, value);
  return "Saved";
}

Future<bool> getReminderValue(String id) async {
  final Future<SharedPreferences> prefs0 = SharedPreferences.getInstance();
  final SharedPreferences prefs = await prefs0;
  return prefs.getBool(id) ?? false;
}

void logout(BuildContext context) async {
  Get.the<PageManager>().dispose();
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
  getIt<PageManager>().playSinglePlaylist(
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
