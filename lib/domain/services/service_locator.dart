import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:sleeptales/domain/blocs/authentication/app_bloc.dart';
import 'package:sleeptales/domain/blocs/authentication/auth_repository.dart';
import 'package:sleeptales/domain/blocs/user/user_bloc.dart';
import 'package:sleeptales/domain/services/user_service.dart';
import 'package:sleeptales/utils/get.dart';

import '../../page_manager.dart';
import 'audio_handler.dart';
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
  // page state
  getIt.registerLazySingleton<PageManager>(() => PageManager());
}
