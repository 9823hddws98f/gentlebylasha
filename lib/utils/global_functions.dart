import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/domain/blocs/user/app_user.dart';
import '/domain/blocs/user/user_bloc.dart';
import '/domain/models/block_item/audio_track.dart';
import '/domain/services/service_locator.dart';
import '/page_manager.dart';
import '/screens/auth/login_screen.dart';
import '/utils/colors.dart';
import '/utils/get.dart';

void showToast(String value) {
  if (kDebugMode) {
    debugPrint('showToast $value');
  }
  Fluttertoast.showToast(msg: value, gravity: ToastGravity.BOTTOM, fontSize: 15);
}

ValueNotifier<String> valueNotifierName = ValueNotifier("");

Future<AppUser> getUser() async {
  // TODO: Implement correctly
  return Get.the<UserBloc>().state.user;
}

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

Future<String> saveUser(AppUser user) async {
  final Future<SharedPreferences> prefs0 = SharedPreferences.getInstance();
  final SharedPreferences prefs = await prefs0;
  prefs.setString("user_id", user.id ?? "null");
  prefs.setString("email", user.email ?? "null");
  prefs.setString("name", user.name ?? "null");
  prefs.setString("language", user.language ?? "en");
  prefs.setString("goals", jsonEncode(user.goals));
  prefs.setString("heardfrom", user.heardFrom ?? "");
  prefs.setString("photourl", user.photoURL ?? "null");
  return "Saved";
}

void logout(BuildContext context) async {
  showLoaderDialog(context, "Logging out...");
  getIt<PageManager>().dispose();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.remove('user_id');
  await preferences.remove('email');
  await preferences.remove('name');
  await preferences.remove('language');
  await preferences.remove('goals');
  await preferences.remove('heardfrom');
  await preferences.remove('photourl');
  await preferences.remove('token');
  await preferences.remove('emailVerification');
  await deleteFavoritesList();
  await deleteFavoritesPlayList();
  final FirebaseAuth auth = FirebaseAuth.instance;
  auth.signOut();

  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (BuildContext context) {
        return LoginScreen();
      },
    ),
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

Future<void> addFavoriteListToSharedPref(List<String> fav) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setStringList("fav_list", fav);
}

Future<List<String>> getFavoriteListFromSharedPref() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getStringList("fav_list") ?? [];
}

Future<void> removeFromFavoritesList(String trackId) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  List<String> favList = preferences.getStringList("fav_list") ?? [];
  favList.remove(trackId);
  addFavoriteListToSharedPref(favList);
}

Future<void> deleteFavoritesList() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.remove("fav_list");
}

Future<void> addFavoritePlayListToSharedPref(List<String> fav) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setStringList("fav_play_list", fav);
}

Future<List<String>> getFavoritePlayListFromSharedPref() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getStringList("fav_play_list") ?? [];
}

Future<void> removeFromFavoritesPlayList(String blockId) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  List<String> favList = preferences.getStringList("fav_play_list") ?? [];
  favList.remove(blockId);
  addFavoritePlayListToSharedPref(favList);
}

Future<void> deleteFavoritesPlayList() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.remove("fav_play_list");
}

void pushRemoveAll(BuildContext context, Widget widget) {
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => widget),
      (Route<dynamic> route) => false);
}

showLoaderDialog(BuildContext context, String message) {
  WillPopScope alert = WillPopScope(
      child: AlertDialog(
        backgroundColor: colorBackground,
        content: Row(
          children: [
            CircularProgressIndicator(
              color: Colors.purple,
            ),
            Expanded(
                flex: 1,
                child: Container(
                    margin: const EdgeInsets.only(left: 7), child: Text(message))),
          ],
        ),
      ),
      onWillPop: () => Future.value(false));
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
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

class SlideFromBottomPageRoute extends PageRouteBuilder {
  final Widget page;

  SlideFromBottomPageRoute({required this.page})
      : super(
            pageBuilder: (_, __, ___) => page,
            transitionsBuilder: (_, animation, __, child) => SlideTransition(
                position: Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)
                    .animate(animation),
                child: child));
}
