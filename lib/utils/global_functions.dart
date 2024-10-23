import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:audio_service/audio_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category_model.dart';
import '../page_manager.dart';
import '../services/service_locator.dart';
import '/models/audiofile_model.dart';
import '/models/user_model.dart';
import '/screens/launch_screen.dart';
import '/utils/colors.dart';

void showToast(String value) =>
    Fluttertoast.showToast(msg: value, gravity: ToastGravity.BOTTOM, fontSize: 15);

ValueNotifier<String> valueNotifierName = ValueNotifier("");

ValueNotifier<int> indexNotifier = ValueNotifier(0);
List<Categories> categroiesArray = [];

fetchCategoriesArrayAndSave() async {
  categroiesArray = await getCategories();
}

Future<UserModel> getUser() async {
  final Future<SharedPreferences> prefs0 = SharedPreferences.getInstance();
  final SharedPreferences prefs = await prefs0;
  String? jsonString = prefs.getString('goals');
  List<dynamic> list = [];
  if (jsonString != null) {
    list = jsonDecode(jsonString);
    // Do something with the list
  }
  return UserModel(
    id: prefs.getString("user_id"),
    email: prefs.getString("email"),
    name: prefs.getString("name"),
    goals: list,
    language: prefs.getString("language"),
    heardFrom: prefs.getString("heardfrom"),
    photoURL: prefs.getString("photourl"),
  );
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

Future<String> saveUser(UserModel user) async {
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
        return LaunchScreen();
      },
    ),
    (_) => false,
  );
}

void pushName(BuildContext context, Widget widget) {
  FocusManager.instance.primaryFocus!.unfocus();
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

playTrack(AudioTrack audioTrack) {
  //getIt<PageManager>().init();
  getIt<PageManager>().playSinglePlaylist(
      MediaItem(
        id: audioTrack.trackId ?? '',
        album: audioTrack.speaker ?? '',
        title: audioTrack.title ?? '',
        displayDescription: audioTrack.description,
        artUri: Uri.parse(audioTrack.imageBackground ?? ''),
        extras: {
          'url': audioTrack.trackUrl,
          'id': audioTrack.trackId,
          'categories': audioTrack.categories[0].categoryName
        },
      ),
      audioTrack.trackId);
}

// Save the list of model objects to shared preferences
Future<void> saveCategories(List<Categories> categories) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String> categoryStrings =
      categories.map((category) => jsonEncode(category.toMap())).toList();

  await prefs.setStringList('categories', categoryStrings);
}

// Retrieve the list of model objects from shared preferences
Future<List<Categories>> getCategories() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String>? categoryStrings = prefs.getStringList('categories');

  if (categoryStrings != null) {
    List<Map<String, dynamic>> categoryMaps = categoryStrings
        .map<Map<String, dynamic>>((category) => jsonDecode(category))
        .toList();
    List<Categories> categories =
        categoryMaps.map((category) => Categories.fromMap(category)).toList();

    return categories;
  }

  return [];
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
