import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/domain/cubits/downloads_cubit.dart';
import '/domain/models/block_item/audio_track.dart';
import '/domain/services/language_cubit.dart';
import '/utils/get.dart';
import '/utils/modals.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/blocks/track_grid.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreen();
}

class _DownloadsScreen extends State<DownloadsScreen> with Translation {
  final _cubit = Get.the<DownloadsCubit>();

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isMobile) => AdaptiveAppBar(
          title: tr.downloads,
          actions: [
            IconButton(
              onPressed: () async {
                final response = await Modals.confirm(
                  context,
                  text: tr.confirmDeleteAllDownloads,
                );
                if (response == true) {
                  _cubit.removeAll();
                }
              },
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
        body: (context, isMobile) => BlocBuilder<DownloadsCubit, List<AudioTrack>>(
          bloc: _cubit,
          builder: (context, state) => state.isEmpty
              ? Center(child: Text(tr.noDownloadsYet))
              : TrackGrid(tracks: state),
        ),
      );
}
