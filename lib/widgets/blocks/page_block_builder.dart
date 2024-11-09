import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/domain/cubits/pages/pages_cubit.dart';
import '/domain/models/app_page.dart';
import '/domain/models/block/block.dart';
import '/screens/home/track_block_loader.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';

class PageBlockBuilder extends StatelessWidget {
  PageBlockBuilder({super.key, required this.page})
      : blocks = null,
        _useBlocks = false;

  PageBlockBuilder.custom({super.key, required List<Block> this.blocks})
      : page = null,
        _useBlocks = true;

  final AppPage? page;
  final List<Block>? blocks;
  final bool _useBlocks;

  final _pagesCubit = Get.the<PagesCubit>();

  @override
  Widget build(BuildContext context) => _useBlocks
      ? _buildBlocksList(blocks!)
      : BlocProvider.value(
          value: _pagesCubit,
          child: BlocBuilder<PagesCubit, PagesState>(
            builder: (context, state) {
              final pageBlocks = state.pages[page] ?? [];
              return _buildBlocksList(pageBlocks);
            },
          ),
        );

  Widget _buildBlocksList(List<Block> blocks) => BottomPanelSpacer.padding(
        child: ListView.separated(
          separatorBuilder: (_, __) => const Padding(
            padding: EdgeInsets.fromLTRB(
              AppTheme.sidePadding,
              16,
              AppTheme.sidePadding,
              8,
            ),
            child: Divider(height: 1),
          ),
          itemCount: blocks.length,
          itemBuilder: (_, index) => TrackBlockLoader(blocks[index]),
        ),
      );
}
