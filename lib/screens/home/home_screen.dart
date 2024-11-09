import 'package:flutter/material.dart';

import '/domain/cubits/pages/pages_cubit.dart';
import '/domain/services/language_constants.dart';
import '/utils/get.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/blocks/page_block_builder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with Translation {
  final _pagesCubit = Get.the<PagesCubit>();

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isMobile) => AdaptiveAppBar(title: tr.home),
        bodyPadding: EdgeInsets.zero,
        body: (context, isMobile) =>
            PageBlockBuilder(page: _pagesCubit.state.pages.keys.first),
      );
}
