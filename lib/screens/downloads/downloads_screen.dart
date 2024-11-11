import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleeptales/domain/cubits/downloads_cubit.dart';
import 'package:sleeptales/domain/models/block_item/audio_track.dart';
import 'package:sleeptales/screens/track_list_screen.dart';
import 'package:sleeptales/utils/get.dart';
import 'package:sleeptales/widgets/app_scaffold/adaptive_app_bar.dart';
import 'package:sleeptales/widgets/app_scaffold/app_scaffold.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreen();
}

class _DownloadsScreen extends State<DownloadsScreen> {
  final _cubit = Get.the<DownloadsCubit>();

  @override
  Widget build(BuildContext context) => BlocBuilder<DownloadsCubit, List<AudioTrack>>(
        bloc: _cubit,
        builder: (context, state) => state.isEmpty
            ? AppScaffold(
                appBar: (context, isMobile) => AdaptiveAppBar(title: 'Downloads'),
                body: (context, isMobile) => Center(child: Text('No downloads yet')),
              )
            : TrackListScreen(heading: 'Downloads', tracks: state),
      );
}
