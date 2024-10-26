import 'package:cached_network_image/cached_network_image.dart';
import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sleeptales/domain/blocs/user/user_bloc.dart';
import 'package:sleeptales/utils/get.dart';

import '/constants/assets.dart';
import '/screens/about_screen.dart';
import '/screens/change_language.dart';
import '/screens/change_password_screen.dart';
import '/screens/delete_account.dart';
import '/screens/downloads_screen.dart';
import '/screens/favorite_playlist_screen.dart';
import '/screens/favorites_screen.dart';
import '/screens/manage_subscription.dart';
import '/screens/reminders_screen.dart';
import '/utils/app_theme.dart';
import '/utils/common_extensions.dart';
import '/utils/global_functions.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '../constants/language_constants.dart';
import 'edit_profile_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final userBloc = Get.the<UserBloc>();

  @override
  Widget build(BuildContext context) {
    final tr = translation();
    final colors = Theme.of(context).colorScheme;
    return AppScaffold(
      appBar: (context, isMobile) => _buildAppBar(tr, colors),
      body: (context, isMobile) => SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 16) + EdgeInsets.only(bottom: 170),
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
                FavoritePlaylistScreen(),
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
              onTap: () => pushName(context, const AboutScreen()),
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
    );
  }

  AppBar _buildAppBar(AppLocalizations tr, ColorScheme colors) {
    return AppBar(
      title: Text(tr.myProfile),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(76),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16) + EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.outline,
              ),
            ),
          ),
          child: BlocProvider.value(
            value: userBloc,
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) => Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox.square(
                    dimension: 60,
                    child: state.user.photoURL?.isNotEmpty ?? false
                        ? CachedNetworkImage(
                            imageUrl: state.user.photoURL!,
                            imageBuilder: (context, imageProvider) => CircleAvatar(
                              backgroundImage: imageProvider,
                              radius: 64,
                            ),
                            placeholder: (context, url) => Image.asset(
                              Assets.profile,
                              fit: BoxFit.cover,
                            ),
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
                        // TODO: Move to firstname lastname
                        Text(
                          state.user.name ?? '',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        InkWell(
                          onTap: () => pushName(context, EditProfileScreen()),
                          child: Text(
                            tr.editProfile,
                            style: TextStyle(
                              color: Colors.white,
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
