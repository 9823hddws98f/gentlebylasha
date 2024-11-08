import 'package:flutter/material.dart';
import 'package:sleeptales/utils/common_extensions.dart';

import '/domain/cubits/pages/pages_cubit.dart';
import '/domain/models/app_page.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key, this.onTap});

  final void Function(int index)? onTap;

  @override
  State<CategoryList> createState() => CategoryListState();
}

class CategoryListState extends State<CategoryList> {
  final _pagesCubit = Get.the<PagesCubit>();

  final Map<int, GlobalKey> _itemKeys = {};

  List<AppPage> _appPages = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _appPages = _pagesCubit.state.explorePages.keys.toList();
  }

  @override
  void dispose() {
    _itemKeys.forEach((_, key) => key.currentState?.dispose());
    _itemKeys.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 47,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        cacheExtent: 600,
        padding: EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
        itemCount: _appPages.length,
        separatorBuilder: (context, index) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          _itemKeys[index] ??= GlobalKey();
          return KeyedSubtree(
            key: _itemKeys[index],
            child: _buildTabButton(
              index,
              colors,
              label: _appPages[index].name,
              onTap: widget.onTap == null ? null : () => widget.onTap!(index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabButton(
    int index,
    ColorScheme colors, {
    required String label,
    required VoidCallback? onTap,
  }) =>
      FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: _selectedIndex == index ? colors.primary : colors.surface,
          foregroundColor: colors.onSurface,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.smallBorderRadius),
          side: BorderSide(color: colors.outline),
        ),
        onPressed: () => _handleTap(index),
        child: Text(label),
      );

  void _handleTap(int index) async {
    widget.onTap?.call(index);
    if (!mounted) return;

    context.size?.height.logDebug();

    setState(() => _selectedIndex = index);
    final key = _itemKeys[index];
    if (key?.currentContext != null) {
      await Scrollable.ensureVisible(
        key!.currentContext!,
        duration: Durations.medium1,
        curve: Easing.standard,
        alignment: 0.5,
      );
    }
  }
}
