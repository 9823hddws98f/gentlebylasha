import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '/domain/blocs/authentication/app_bloc.dart';
import '/domain/blocs/authentication/auth_repository.dart';
import '/domain/blocs/user/user_bloc.dart';
import '/domain/cubits/downloads_cubit.dart';
import '/domain/cubits/favorite_playlists.dart';
import '/domain/cubits/favorite_tracks.dart';
import '/domain/cubits/in_app_purchases/iap_cubit.dart';
import '/domain/cubits/in_app_purchases/iap_service.dart';
import '/domain/cubits/pages/pages_cubit.dart';
import '/utils/get.dart';
import 'account_deletion_service.dart';
import 'analytics_service.dart';
import 'app_settings.dart';
import 'audio_handler.dart';
import 'audio_manager.dart';
import 'audio_panel_manager.dart';
import 'audio_timer_service.dart';
import 'deep_linking_service.dart';
import 'downloads_service.dart';
import 'in_app_purchases/mobile_iap_service.dart';
import 'in_app_purchases/web_iap_service.dart';
import 'interfaces/app_settings_view.dart';
import 'interfaces/in_app_purchases.dart';
import 'language_cubit.dart';
import 'mailing_service.dart';
import 'playlists_service.dart';
import 'reminder_service.dart';
import 'sendgrid_mailing_service.dart';
import 'storage_service.dart';
import 'tracks_service.dart';
import 'user_service.dart';

Future<void> setupServiceLocator() async {
  const isWeb = kIsWeb;

  /// Services
  _reg<AnalyticsService>(AnalyticsService.instance);
  _reg<DeepLinkingService>(DeepLinkingService.instance);
  _reg<AudioHandler>(await initAudioService());
  _reg<InAppPurchases>(isWeb ? WebIapService.instance : MobileIapService.instance);
  _reg<IAPCubit>(IAPCubit.instance);
  // Only initialized when first called
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
  _regLazy<PurchasesApi>(() => PurchasesApi.instance);

  /// Blocs/Cubits
  _regLazy<AppBloc>(() => AppBloc(Get.the<AuthRepository>()));
  _regLazy<UserBloc>(() => UserBloc(Get.the<UsersService>()));
  _regLazy<FavoritesTracksCubit>(() => FavoritesTracksCubit.instance);
  _regLazy<FavoritePlaylistsCubit>(() => FavoritePlaylistsCubit.instance);
  _regLazy<PagesCubit>(() => PagesCubit.instance);
  _regLazy<AudioManager>(() => AudioManager.instance);
  _regLazy<DownloadsCubit>(() => DownloadsCubit.instance);
}

void _reg<T extends Object>(T instance) => GetIt.instance.registerSingleton<T>(instance);

void _regLazy<T extends Object>(T Function() factoryFunc) =>
    GetIt.instance.registerLazySingleton<T>(factoryFunc);
