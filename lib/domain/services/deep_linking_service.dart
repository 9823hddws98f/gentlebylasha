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

  bool _listening = false;

  /// The signed-in app on screen (an AppContainer); null when signed out.
  Object? _screen;

  /// Premium and favorites of the signed-in account are loaded (UserBloc).
  bool _accountReady = false;

  /// A link that arrived while it couldn't be opened yet (signed out, or the
  /// app was still starting); opened once the account is ready.
  SharedLink? _pending;

  /// Starts listening for links; safe to call more than once. Called at app
  /// start, so links that arrive while signed out are kept. On iOS and
  /// Android the stream also delivers the link that opened the app, on the
  /// web the page URL.
  void initialize() {
    if (_listening) return;
    _listening = true;
    _appLinks.uriLinkStream.listen(
      _onLink,
      onError: (err) {
        debugPrint('Deep link error: $err');
        showToast(_tr.linkInvalid);
      },
    );
  }

  /// The signed-in app ([screen]) is shown; opens a link that is waiting.
  void attach(Object screen) {
    initialize();
    _screen = screen;
    _openPending();
  }

  /// [screen] is gone (logout); links wait for the next sign-in. A newer
  /// screen that attached in the meantime stays attached.
  void detach(Object screen) {
    if (identical(_screen, screen)) _screen = null;
  }

  /// Whether the signed-in account is loaded; opens a link that is waiting.
  void setAccountReady(bool ready) {
    _accountReady = ready;
    _openPending();
  }

  bool get _canOpen => _screen != null && _accountReady && _isUserLoggedIn();

  void _onLink(Uri uri) {
    final link = SharedLink.parse(uri);
    if (link == null) return;
    if (_canOpen) {
      _open(link);
    } else {
      _pending = link;
    }
  }

  void _openPending() {
    final link = _pending;
    if (link == null || !_canOpen) return;
    _pending = null;
    _open(link);
  }

  Future<void> _open(SharedLink link) async {
    switch (link.type) {
      case SharedLink.track:
        await _handleTrackDeepLink(link.id);
      case SharedLink.playlist:
        await _handlePlaylistDeepLink(link.id);
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
        _createDeepLink(SharedLink.track, trackId),
      );

  void sharePlaylist(String playlistId) => Share.share(
        _createDeepLink(SharedLink.playlist, playlistId),
      );

  String _createDeepLink(String type, String id) => AppConfig.shareLink(type, id);
}

/// A shared track or playlist link: `<APP_URL>/<type>/<id>`.
class SharedLink {
  const SharedLink(this.type, this.id);

  static const track = 'shareTrack';
  static const playlist = 'sharePlaylist';

  final String type;
  final String id;

  /// null when [uri] has no `<type>/<id>` path (e.g. the web app's start page).
  static SharedLink? parse(Uri uri) {
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length < 2) return null;
    return SharedLink(segments[0], segments[1]);
  }
}
