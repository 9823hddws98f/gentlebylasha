import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';

import '/domain/blocs/authentication/app_bloc.dart';
import '/domain/blocs/authentication/auth_repository.dart';
import '/domain/blocs/user/user_bloc.dart';
import '/domain/cubits/favorite_playlists.dart';
import '/domain/cubits/pages/pages_cubit.dart';
import '/domain/services/user_service.dart';
import '/page_manager.dart';
import '/utils/get.dart';
import '../cubits/favorite_tracks.dart';
import 'audio_handler.dart';
import 'audio_panel_manager.dart';
import 'language_constants.dart';
import 'playlist_repository.dart';
import 'playlists_service.dart';
import 'tracks_service.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  /// services
  getIt.registerSingleton<AudioHandler>(await initAudioService());
  getIt.registerLazySingleton<PlaylistRepository>(() => DemoPlaylist());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());
  getIt.registerLazySingleton<UsersService>(() => UsersService());
  getIt.registerLazySingleton<AudioPanelManager>(() => AudioPanelManager.instance);
  getIt.registerLazySingleton<TranslationService>(() => TranslationService.instance);
  getIt.registerLazySingleton<TracksService>(() => TracksService.instance);
  getIt.registerLazySingleton<PlaylistsService>(() => PlaylistsService.instance);

  /// Blocs
  getIt.registerLazySingleton<AppBloc>(() => AppBloc(Get.the<AuthRepository>()));
  getIt.registerLazySingleton<UserBloc>(() => UserBloc(Get.the<UsersService>()));
  getIt.registerLazySingleton<FavoritesTracksCubit>(() => FavoritesTracksCubit.instance);
  getIt.registerLazySingleton<FavoritePlaylistsCubit>(
      () => FavoritePlaylistsCubit.instance);
  getIt.registerLazySingleton<PagesCubit>(() => PagesCubit.instance);
  getIt.registerLazySingleton<PageManager>(() => PageManager());
}

Future<void> initUserBasedServices() async {
  await Get.the<FavoritesTracksCubit>().init();
  await Get.the<FavoritePlaylistsCubit>().init();
}
