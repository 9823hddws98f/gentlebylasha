import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/domain/cubits/pages/pages_cubit.dart';
import '/domain/services/language_cubit.dart';
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
        appBar: (context, isMobile) => AdaptiveAppBar(
          title: tr.home,
          hasBottomLine: false,
        ),
        bodyPadding: EdgeInsets.zero,
        // Content can arrive after this screen opens (sign-in navigates first).
        body: (context, isMobile) => BlocBuilder<PagesCubit, PagesState>(
          bloc: _pagesCubit,
          builder: (context, state) => state.pages.isEmpty
              ? const Center(child: Icon(Icons.nightlight_round, size: 48))
              : PageBlockBuilder(page: state.pages.keys.first),
        ),
      );
}
