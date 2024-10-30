import 'package:flutter/material.dart';

import '/domain/models/category_block.dart';
import '/utils/app_theme.dart';
import '/utils/firestore_helper.dart';
import '/utils/tx_loader.dart';
import '/widgets/shimmerwidgets/shimmerize.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({
    super.key,
    this.showSelection = true,
    this.onTap,
    this.onLoad,
  });

  final bool showSelection;
  final void Function(int index)? onTap;
  final void Function(List<CategoryBlock> categoryBlocks)? onLoad;
  @override
  State<CategoryList> createState() => CategoryListState();
}

class CategoryListState extends State<CategoryList> {
  final _txLoader = TxLoader();

  final Map<int, GlobalKey> _itemKeys = {};

  List<CategoryBlock> _categoryBlocks = [];
  int _selectedIndex = 0;

  void handleTap(int index) async {
    widget.onTap?.call(index);
    if (mounted) {
      setState(() => _selectedIndex = index);
    }

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

  @override
  void initState() {
    super.initState();
    _txLoader.load(
      () => getCategoryBlocks(),
      onSuccess: (items) {
        widget.onLoad?.call(items);
        if (mounted) {
          setState(() => _categoryBlocks = items);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 47,
      child: _txLoader.loading
          ? _buildShimmer()
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              cacheExtent: 600,
              padding: EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
              itemCount: _categoryBlocks.length,
              separatorBuilder: (context, index) => SizedBox(width: 8),
              itemBuilder: (context, index) {
                _itemKeys[index] ??= GlobalKey();
                return KeyedSubtree(
                  key: _itemKeys[index],
                  child: _buildTabButton(
                    index,
                    colors,
                    label: _categoryBlocks[index].name,
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
          backgroundColor: (widget.showSelection && _selectedIndex == index)
              ? colors.primary
              : colors.surface,
          foregroundColor: colors.onSurface,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.smallBorderRadius),
          side: BorderSide(color: colors.outline),
        ),
        onPressed: () => handleTap(index),
        child: Text(label),
      );

  Widget _buildShimmer() => ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
        separatorBuilder: (context, index) => SizedBox(width: 8),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) => Shimmerize(
          child: FilledButton(
            onPressed: null,
            child: const SizedBox(width: 60),
          ),
        ),
      );

  @override
  void dispose() {
    _itemKeys.clear();
    super.dispose();
  }
}
