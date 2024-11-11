import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/constants/assets.dart';
import '/domain/blocs/user/user_bloc.dart';
import '/domain/services/language_cubit.dart';
import '/screens/change_language.dart';
import '/screens/change_password_screen.dart';
import '/screens/delete_account.dart';
import 'downloads/downloads_screen.dart';
import '/screens/favorites_screen.dart';
import '/screens/manage_subscription.dart';
import '/screens/reminders_screen.dart';
import '/utils/app_theme.dart';
import '/utils/common_extensions.dart';
import '/utils/get.dart';
import '/utils/global_functions.dart';
import '/widgets/app_image.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';
import 'about/about_screen.dart';
import 'edit_profile/edit_profile_screen.dart';

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
                  FavoritesScreen(),
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
                      ? AppImage(
                          imageUrl: state.user.photoURL!,
                          borderRadius: BorderRadius.circular(64),
                          placeholderAsset: Assets.profile,
                          errorWidget: (context, url, error) => Image.asset(
                            Assets.profile,
                            fit: BoxFit.cover,
                          ),
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
      InkWell(
        onTap: onTap,
        borderRadius: AppTheme.smallBorderRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.outline),
            borderRadius: AppTheme.smallBorderRadius,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: isLogout ? colors.error : colors.onSurface, size: 20),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: isLogout ? colors.error : colors.onSurface),
                ),
              ),
              if (!isLogout) Icon(Icons.arrow_forward, color: colors.onSurface, size: 20),
            ],
          ),
        ),
      );
}
