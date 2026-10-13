import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/domain/cubits/downloads_cubit.dart';
import '/domain/models/block_item/audio_track.dart';
import '/domain/services/language_cubit.dart';
import '/helper/global_functions.dart';
import '/helper/premium_gate.dart';
import '/utils/get.dart';

class TrackDownloadButton extends StatefulWidget {
  const TrackDownloadButton({
    super.key,
    required this.track,
  });

  final AudioTrack? track;

  @override
  State<TrackDownloadButton> createState() => _TrackDownloadButtonState();
}

class _TrackDownloadButtonState extends State<TrackDownloadButton> with Translation {
  final _cubit = Get.the<DownloadsCubit>();

  bool _downloading = false;

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          BlocBuilder<DownloadsCubit, List<AudioTrack>>(
            bloc: _cubit,
            builder: (context, state) {
              final downloaded = state.any((t) => t.id == widget.track?.id);
              return IconButton(
                icon: downloaded ? Icon(Icons.download_done) : Icon(Icons.download_rounded),
                onPressed: widget.track != null && !downloaded ? _saveFile : null,
              );
            },
          ),
          if (_downloading)
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      );

  Future<void> _saveFile() async {
    if (!requireAccess(widget.track!)) return;
    setState(() => _downloading = true);
    try {
      await _cubit.downloadTrack(widget.track!);
    } catch (_) {
      showToast(tr.downloadFailed);
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }
}
