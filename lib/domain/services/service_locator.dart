import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';

import '/domain/blocs/authentication/app_bloc.dart';
import '/domain/blocs/authentication/auth_repository.dart';
import '/domain/blocs/user/user_bloc.dart';
import '/domain/cubits/downloads_cubit.dart';
import '/domain/cubits/favorite_playlists.dart';
import '/domain/cubits/favorite_tracks.dart';
import '/domain/cubits/pages/pages_cubit.dart';
import '/page_manager.dart';
import '/utils/get.dart';
import 'account_deletion_service.dart';
import 'app_settings.dart';
import 'audio_handler.dart';
import 'audio_panel_manager.dart';
import 'audio_timer_service.dart';
import 'downloads_service.dart';
import 'interfaces/app_settings_view.dart';
import 'language_cubit.dart';
import 'mailing_service.dart';
import 'playlists_service.dart';
import 'reminder_service.dart';
import 'sendgrid_mailing_service.dart';
import 'storage_service.dart';
import 'tracks_service.dart';
import 'user_service.dart';

Future<void> setupServiceLocator() async {
  /// Services
  GetIt.instance.registerSingleton<AudioHandler>(await initAudioService());
  _regLazy<AuthRepository>(() => AuthRepository());
  _regLazy<UsersService>(() => UsersService());
  _regLazy<AudioPanelManager>(() => AudioPanelManager.instance);
  _regLazy<LanguageCubit>(() => LanguageCubit.instance);
  _regLazy<TracksService>(() => TracksService.instance);
  _regLazy<PlaylistsService>(() => PlaylistsService.instance);
  _regLazy<StorageService>(() => StorageService.instance);
  _regLazy<DownloadsService>(() => DownloadsService.instance);
  _regLazy<MailingService>(() => SendGridMailingService.instance);
  _regLazy<AccountDeletionService>(() => AccountDeletionService.instance);
  _regLazy<AppSettings>(() => AppSettings.instance);
  _regLazy<AppSettingsView>(() => AppSettings.instance);
  _regLazy<ReminderService>(() => ReminderService.instance);
  _regLazy<AudioTimerService>(() => AudioTimerService.instance);

  /// Blocs/Cubits
  _regLazy<AppBloc>(() => AppBloc(Get.the<AuthRepository>()));
  _regLazy<UserBloc>(() => UserBloc(Get.the<UsersService>()));
  _regLazy<FavoritesTracksCubit>(() => FavoritesTracksCubit.instance);
  _regLazy<FavoritePlaylistsCubit>(() => FavoritePlaylistsCubit.instance);
  _regLazy<PagesCubit>(() => PagesCubit.instance);
  _regLazy<PageManager>(() => PageManager());
  _regLazy<DownloadsCubit>(() => DownloadsCubit.instance);
}

void _regLazy<T extends Object>(T Function() factoryFunc) =>
    GetIt.instance.registerLazySingleton<T>(factoryFunc);
