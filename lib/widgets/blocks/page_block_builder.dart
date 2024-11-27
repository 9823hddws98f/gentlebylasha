import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gentle/widgets/blocks/config_of_page.dart';

import '/domain/cubits/pages/pages_cubit.dart';
import '/domain/models/app_page/app_page.dart';
import '/domain/models/block/block.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';
import 'track_block_loader.dart';

class PageBlockBuilder extends StatefulWidget {
  const PageBlockBuilder({super.key, required this.page});

  final AppPage page;

  @override
  State<PageBlockBuilder> createState() => _PageBlockBuilderState();
}

class _PageBlockBuilderState extends State<PageBlockBuilder>
    with AutomaticKeepAliveClientMixin {
  final _pagesCubit = Get.the<PagesCubit>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<PagesCubit, PagesState>(
      bloc: _pagesCubit,
      builder: (context, state) => PageConfig(
        config: widget.page.config,
        child: _buildBlocksList(state.pages[widget.page] ?? []),
      ),
    );
  }

  Widget _buildBlocksList(List<Block> blocks) => BottomPanelSpacer.padding(
        child: ListView.separated(
          cacheExtent: 1000,
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
