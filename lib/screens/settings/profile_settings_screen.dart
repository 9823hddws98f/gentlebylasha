import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supa_carbon_icons/supa_carbon_icons.dart';

import '/domain/blocs/user/user_bloc.dart';
import '/domain/services/language_cubit.dart';
import '/helper/global_functions.dart';
import '/screens/about/about_screen.dart';
import '/screens/downloads/downloads_screen.dart';
import '/screens/favorites/favorites_screen.dart';
import '/screens/reminder/reminders_screen.dart';
import '/screens/settings/display_mode/display_mode_screen.dart';
import '/utils/app_theme.dart';
import '/utils/common_extensions.dart';
import '/utils/get.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';
import 'change_language/change_language.dart';
import 'change_password/change_password_screen.dart';
import 'delete_account/delete_account_screen.dart';
import 'edit_profile/edit_profile_screen.dart';
import 'subscription/manage_subscription.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> with Translation {
  final _userBloc = Get.the<UserBloc>();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppScaffold(
      appBar: (context, isMobile) => _buildAppBar(colors),
      body: (context, isMobile) => BottomPanelSpacer.padding(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              _buildListTile(
                icon: Icons.favorite,
                title: tr.favoriteList,
                colors: colors,
                onTap: () => pushName(
                  context,
                  const FavoritesScreen(),
                ),
              ),
              _buildListTile(
                icon: Icons.playlist_add_check,
                title: tr.favoritePlaylist,
                colors: colors,
                onTap: () => pushName(
                  context,
                  const FavoritesScreen.playlist(),
                ),
              ),
              _buildListTile(
                icon: Icons.download,
                title: tr.downloads,
                colors: colors,
                onTap: () => pushName(context, DownloadsScreen()),
              ),
              Divider(height: 24),
              _buildListTile(
                icon: Icons.lock,
                title: tr.changePassword,
                colors: colors,
                onTap: () => pushName(context, ChangePasswordScreen()),
              ),
              if (!kIsWeb && !Platform.isMacOS)
                _buildListTile(
                  icon: Icons.punch_clock_rounded,
                  title: tr.reminders,
                  colors: colors,
                  onTap: () => pushName(context, RemindersScreen()),
                ),
              _buildListTile(
                icon: Icons.subscriptions,
                title: tr.manageSubscription,
                colors: colors,
                onTap: () => pushName(context, ManageSubscriptionScreen()),
              ),
              Divider(height: 24),
              _buildListTile(
                icon: Icons.language,
                title: tr.changeLanguage,
                colors: colors,
                onTap: () => pushName(context, ChangeLanguageScreen()),
              ),
              _buildListTile(
                icon: Icons.display_settings,
                title: 'Display mode',
                colors: colors,
                onTap: () => pushName(context, DisplayModeScreen()),
              ),
              _buildListTile(
                icon: Icons.help_center,
                title: tr.helpSupport,
                colors: colors,
                onTap: () {
                  // TODO: Implement
                  showToast('Coming soon');
                },
              ),
              _buildListTile(
                icon: Icons.info,
                title: tr.about,
                colors: colors,
                onTap: () => pushName(context, AboutScreen()),
              ),
              _buildListTile(
                icon: Icons.account_circle,
                title: tr.deleteAccount,
                colors: colors,
                onTap: () => pushName(context, const DeleteAccountScreen()),
              ),
              Divider(height: 24),
              _buildListTile(
                icon: Icons.logout,
                title: tr.logout,
                colors: colors,
                isLogout: true,
                onTap: () => logout(context),
              ),
            ].interleaveWith(SizedBox(height: 10)),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(ColorScheme colors) {
    return AdaptiveAppBar(
      title: tr.myProfile,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(76),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16) + EdgeInsets.only(bottom: 16),
          child: BlocBuilder<UserBloc, UserState>(
            bloc: _userBloc,
            builder: (context, state) => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox.square(
                  dimension: 60,
                  child: state.user.photoURL?.isNotEmpty ?? false
                      ? Image.network(
                          state.user.photoURL!,
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
                              ClipRRect(
                            borderRadius: BorderRadius.circular(64),
                            child: child,
                          ), // TODO: CHECK
                        )
                      : Icon(
                          CarbonIcons.user_avatar_filled_alt,
                          size: 56,
                        ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.user.name ?? '',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      InkWell(
                        onTap: () => pushName(context, EditProfileScreen()),
                        child: Text(
                          tr.editProfile,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ColorScheme colors,
    bool isLogout = false,
  }) =>
      ListTile(
        leading: Icon(icon, color: isLogout ? colors.error : null, size: 20),
        title: Text(
          title,
          style: TextStyle(color: isLogout ? colors.error : null),
        ),
        trailing: !isLogout
            ? Icon(Icons.arrow_forward, color: colors.onSurface, size: 20)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.smallBorderRadius,
          side: BorderSide(color: colors.outline),
        ),
        onTap: onTap,
      );
}
