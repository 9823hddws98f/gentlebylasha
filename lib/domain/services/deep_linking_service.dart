import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gentle/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '/domain/models/block_item/audio_track.dart';
import '/domain/services/audio_panel_manager.dart';
import '/domain/services/language_cubit.dart';
import '/domain/services/playlists_service.dart';
import '/domain/services/tracks_service.dart';
import '/helper/global_functions.dart';
import '/main.dart';
import '/screens/home/playlist_tracks_screen.dart';
import '/utils/app_config.dart';
import '/utils/get.dart';

/// Shared track/playlist links (`<APP_URL>/shareTrack/<id>`). The host is
/// AppConfig.appUrl; Android App Links (appLinkHost in build.gradle.kts) and the
/// iOS associated domain (Runner.entitlements) must use the same host, and that
/// host must serve /.well-known/assetlinks.json and apple-app-site-association.
class DeepLinkingService {
  DeepLinkingService._();
  static final instance = DeepLinkingService._();

  final _appLinks = AppLinks();
  late final _audioPanelManager = Get.the<AudioPanelManager>();
  late final _tracksService = Get.the<TracksService>();
  late final _playlistsService = Get.the<PlaylistsService>();

  BuildContext get _context => MyApp.navigatorKey.currentContext!;

  AppLocalizations get _tr => Get.the<LanguageCubit>().translation;

  void initialize() {
    _appLinks.uriLinkStream.listen(
      (uri) => _handleDeepLink(uri),
      onError: (err) {
        debugPrint('Deep link error: $err');
        showToast(_tr.linkInvalid);
      },
    );

    // Handle initial deep link for cold start
    _appLinks.getInitialLink().then(_handleDeepLink);
  }

  Future<void> _handleDeepLink(Uri? uri) async {
    if (uri == null || uri.pathSegments.isEmpty) return;

    if (!_isUserLoggedIn()) return;

    final segments = uri.pathSegments;
    final id = segments.length > 1 ? segments[1] : null;
    if (id == null) return;

    switch (segments[0]) {
      case 'shareTrack':
        await _handleTrackDeepLink(id);
      case 'sharePlaylist':
        await _handlePlaylistDeepLink(id);
      default:
        showToast(_tr.linkInvalid);
    }
  }

  Future<void> _handleTrackDeepLink(String trackId) async {
    try {
      // Add retry logic for cold start scenarios
      AudioTrack? track;

      track = await _tracksService.getById(trackId);

      showToast(_tr.playingTrack(track.title));

      await playTrack(track).then((ok) {
        if (ok) _audioPanelManager.maximizeAndPlay(false);
      });
    } catch (e) {
      showToast(_tr.trackNotFound);
    }
  }

  Future<void> _handlePlaylistDeepLink(String playlistId) async {
    try {
      final playlist = await _playlistsService.getById(playlistId);
      if (!_context.mounted) return;
      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) => PlayListTracksScreen(playlist: playlist),
        ),
      );
    } catch (e) {
      showToast(_tr.playlistNotFound);
    }
  }

  bool _isUserLoggedIn() => FirebaseAuth.instance.currentUser != null;

  void shareTrack(String trackId) => Share.share(
        _createDeepLink('shareTrack', trackId),
      );

  void sharePlaylist(String playlistId) => Share.share(
        _createDeepLink('sharePlaylist', playlistId),
      );

  String _createDeepLink(String type, String id) => AppConfig.shareLink(type, id);
}
