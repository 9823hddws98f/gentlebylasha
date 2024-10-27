import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';

import '/domain/blocs/authentication/app_bloc.dart';
import '/domain/blocs/authentication/auth_repository.dart';
import '/domain/blocs/user/user_bloc.dart';
import '/domain/services/user_service.dart';
import '/utils/get.dart';
import '../../page_manager.dart';
import 'audio_handler.dart';
import 'audio_panel_manager.dart';
import 'language_constants.dart';
import 'playlist_repository.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // services
  getIt.registerSingleton<AudioHandler>(await initAudioService());
  getIt.registerLazySingleton<PlaylistRepository>(() => DemoPlaylist());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());
  getIt.registerLazySingleton<UsersService>(() => UsersService());
  getIt.registerLazySingleton<AppBloc>(() => AppBloc(Get.the<AuthRepository>()));
  getIt.registerLazySingleton<UserBloc>(() => UserBloc(Get.the<UsersService>()));
  getIt.registerLazySingleton<AudioPanelManager>(() => AudioPanelManager.instance);
  getIt.registerLazySingleton<TranslationService>(() => TranslationService.instance);
  // page state
  getIt.registerLazySingleton<PageManager>(() => PageManager());
}
