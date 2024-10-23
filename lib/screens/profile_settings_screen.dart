import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/language_constants.dart';
import '/models/user_model.dart';
import '/screens/about_screen.dart';
import '/screens/change_language.dart';
import '/screens/change_password_screen.dart';
import '/screens/delete_account.dart';
import '/screens/downloads_screen.dart';
import '/screens/edit_profile_screen.dart';
import '/screens/favorite_playlist_screen.dart';
import '/screens/favorites_screen.dart';
import '/screens/manage_subscription.dart';
import '/screens/reminders_screen.dart';
import '/utils/colors.dart';
import '/utils/global_functions.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final Function panelFunction;
  const ProfileSettingsScreen(this.panelFunction, {super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  @override
  void initState() {
    super.initState();
    getUserFromPref();
  }

  UserModel? user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          translation(context).myProfile,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: user?.photoURL != null
                        ? CachedNetworkImage(
                            imageUrl: user!.photoURL!,
                            imageBuilder: (context, imageProvider) => CircleAvatar(
                              backgroundImage: imageProvider,
                              radius: 64,
                            ),
                            placeholder: (context, url) => Image.asset(
                              "images/profile.png",
                              fit: BoxFit.cover,
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              "images/profile.png",
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            "images/profile.png",
                            fit: BoxFit.cover,
                          ),
                  ),
                  SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 5),
                        child:
                            // Text(
                            //   user?.name??"",
                            //   style: TextStyle(
                            //     fontSize: 20.0,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            ValueListenableBuilder<String>(
                          valueListenable: valueNotifierName,
                          builder: (BuildContext context, String value, Widget? child) {
                            return Text(value,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                ));
                          },
                        ),
                      ),
                      SizedBox(height: 5.0),
                      TextButton(
                        onPressed: () async {
                          pushName(context, EditProfileScreen());
                        },
                        child: Text(
                          translation(context).editProfile,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Divider(
                height: 3.0,
                color: lightBlueColor,
              ),
            ),
            ListTile(
              leading: Icon(Icons.favorite, color: Colors.white, size: 20),
              title: Text(translation(context).favoriteList),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 24,
              ),
              onTap: () {
                pushName(
                    context,
                    FavoritesScreen(
                      panelFunction: widget.panelFunction,
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.playlist_add_check, color: Colors.white, size: 20),
              title: Text(translation(context).favoritePlaylist),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 24,
              ),
              onTap: () {
                pushName(
                    context,
                    FavoritePlaylistScreen(
                      panelFunction: widget.panelFunction,
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: Colors.white, size: 20),
              title: Text(translation(context).downloads),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                pushName(context, DownloadsScreen());
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Divider(
                height: 3.0,
                color: lightBlueColor,
              ),
            ),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.white, size: 20),
              title: Text(translation(context).changePassword),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                pushName(context, ChangePasswordScreen());
              },
            ),
            ListTile(
              leading: Icon(Icons.punch_clock_rounded, color: Colors.white, size: 20),
              title: Text(translation(context).reminders),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                pushName(context, RemindersScreen());
              },
            ),
            ListTile(
              leading: Icon(Icons.subscriptions, color: Colors.white, size: 20),
              title: Text(translation(context).manageSubscription),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                pushName(context, ManageSubscriptionScreen());
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Divider(
                height: 3.0,
                color: lightBlueColor,
              ),
            ),
            ListTile(
              leading: Icon(Icons.language, color: Colors.white, size: 20),
              title: Text(translation(context).changeLanguage),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                pushName(context, ChangeLanguageScreen());
              },
            ),
            ListTile(
              leading: Icon(Icons.help_center, color: Colors.white, size: 20),
              title: Text(translation(context).helpSupport),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.info,
                color: Colors.white,
                size: 20,
              ),
              title: Text(translation(context).about),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                pushName(context, const AboutScreen());
              },
            ),
            ListTile(
              leading: Icon(
                Icons.account_circle,
                color: Colors.white,
                size: 20,
              ),
              title: Text(translation(context).deleteAccount),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                pushName(context, const DeleteAccountScreen());
              },
            ),
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                    onPressed: () {
                      logout(context);
                    },
                    child: Text(
                      translation(context).logout,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                          fontSize: 18),
                    )),
              ),
            ),
            SizedBox(
              height: 150,
            )
          ],
        ),
      ),
    );
  }

  void getUserFromPref() async {
    user = await getUser();
    valueNotifierName.value = user!.name!;
    setState(() {});
  }
}
