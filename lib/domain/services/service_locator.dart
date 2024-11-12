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
import '/domain/services/downloads_service.dart';
import '/domain/services/language_cubit.dart';
import '/domain/services/storage_service.dart';
import '/domain/services/user_service.dart';
import '/page_manager.dart';
import '/utils/get.dart';
import 'audio_handler.dart';
import 'audio_panel_manager.dart';
import 'playlist_repository.dart';
import 'playlists_service.dart';
import 'tracks_service.dart';

Future<void> setupServiceLocator() async {
  /// services
  GetIt.instance.registerSingleton<AudioHandler>(await initAudioService());
  _regLazy<PlaylistRepository>(() => DemoPlaylist());
  _regLazy<AuthRepository>(() => AuthRepository());
  _regLazy<UsersService>(() => UsersService());
  _regLazy<AudioPanelManager>(() => AudioPanelManager.instance);
  _regLazy<LanguageCubit>(() => LanguageCubit.instance);
  _regLazy<TracksService>(() => TracksService.instance);
  _regLazy<PlaylistsService>(() => PlaylistsService.instance);
  _regLazy<StorageService>(() => StorageService.instance);
  _regLazy<DownloadsService>(() => DownloadsService.instance);

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
