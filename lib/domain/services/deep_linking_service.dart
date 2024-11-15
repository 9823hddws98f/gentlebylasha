import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '/domain/models/block_item/audio_track.dart';
import '/domain/services/audio_panel_manager.dart';
import '/domain/services/playlists_service.dart';
import '/domain/services/tracks_service.dart';
import '/helper/global_functions.dart';
import '/main.dart';
import '/screens/home/playlist_tracks_screen.dart';
import '/utils/get.dart';

class DeepLinkingService {
  static const _baseUrl = 'https://www.gentle-mu.vercel.app';

  DeepLinkingService._();
  static final instance = DeepLinkingService._();

  final _appLinks = AppLinks();
  late final _audioPanelManager = Get.the<AudioPanelManager>();
  late final _tracksService = Get.the<TracksService>();
  late final _playlistsService = Get.the<PlaylistsService>();

  BuildContext get _context => MyApp.navigatorKey.currentContext!;

  void initialize() {
    _appLinks.uriLinkStream.listen(
      (uri) => _handleDeepLink(uri),
      onError: (err) => showToast('Deep link error: $err'),
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
        showToast('Invalid deep link');
    }
  }

  Future<void> _handleTrackDeepLink(String trackId) async {
    try {
      // Add retry logic for cold start scenarios
      AudioTrack? track;

      track = await _tracksService.getById(trackId);

      showToast('Playing track: ${track.title}');

      playTrack(track);
      _audioPanelManager.maximizeAndPlay(false);
    } catch (e) {
      showToast('Track not found');
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
      showToast('Playlist not found');
    }
  }

  bool _isUserLoggedIn() => FirebaseAuth.instance.currentUser != null;

  void shareTrack(String trackId) => Share.share(
        _createDeepLink('shareTrack', trackId),
      );

  void sharePlaylist(String playlistId) => Share.share(
        _createDeepLink('sharePlaylist', playlistId),
      );

  String _createDeepLink(String type, String id) => '$_baseUrl/$type/$id';
}
