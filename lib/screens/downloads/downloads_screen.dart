import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supa_carbon_icons/supa_carbon_icons.dart';

import '/domain/cubits/downloads_cubit.dart';
import '/domain/models/block_item/audio_track.dart';
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

class _DownloadsScreen extends State<DownloadsScreen> {
  final _cubit = Get.the<DownloadsCubit>();

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isMobile) => AdaptiveAppBar(
          title: 'Downloads',
          actions: [
            IconButton(
              onPressed: () async {
                final response = await Modals.confirm(
                  context,
                  text: 'Are you sure you want to delete all downloads?',
                );
                if (response == true) {
                  _cubit.removeAll();
                }
              },
              icon: const Icon(CarbonIcons.delete),
            ),
          ],
        ),
        body: (context, isMobile) => BlocBuilder<DownloadsCubit, List<AudioTrack>>(
          bloc: _cubit,
          builder: (context, state) => state.isEmpty
              ? const Center(child: Text('No downloads yet'))
              : TrackGrid(tracks: state),
        ),
      );
}
