import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/domain/cubits/pages/pages_cubit.dart';
import '/domain/models/app_page.dart';
import '/screens/home/track_block_loader.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';

class PageBlockBuilder extends StatelessWidget {
  PageBlockBuilder({super.key, required this.page});

  final AppPage page;

  final _pagesCubit = Get.the<PagesCubit>();

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: _pagesCubit,
        child: BlocBuilder<PagesCubit, PagesState>(
          builder: (context, state) {
            final blocks = state.pages[page] ?? [];
            return SliverList.separated(
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
            );
          },
        ),
      );
}
