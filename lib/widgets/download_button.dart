import 'dart:async';

import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/domain/cubits/downloads_cubit.dart';
import '/domain/models/block_item/audio_track.dart';

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

class _TrackDownloadButtonState extends State<TrackDownloadButton> {
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
                icon: downloaded ? Icon(Icons.download_done) : Icon(CarbonIcons.download),
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
    setState(() => _downloading = true);
    await _cubit.downloadTrack(widget.track!);
    setState(() => _downloading = false);
  }
}
