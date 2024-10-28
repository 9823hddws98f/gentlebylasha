import 'package:flutter/material.dart';
import 'package:sleeptales/utils/tx_loader.dart';

import '/domain/models/category_block.dart';
import '/utils/app_theme.dart';
import '/utils/firestore_helper.dart';
import '/widgets/shimmerwidgets/shimmerize.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({
    super.key,
    this.onTap,
    this.onLoad,
    this.selectedTabIndex,
  });

  final int? selectedTabIndex;
  final void Function(CategoryBlock categoryBlock)? onTap;
  final void Function(List<CategoryBlock> categoryBlocks)? onLoad;
  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final _txLoader = TxLoader();

  List<CategoryBlock> _categoryBlocks = [];

  @override
  void initState() {
    super.initState();
    _txLoader.load(
      () => getCategoryBlocks(),
      onSuccess: (items) {
        widget.onLoad?.call(items);
        if (mounted) {
          setState(() {
            _categoryBlocks = items;
          });
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
              padding: EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
              scrollDirection: Axis.horizontal,
              itemCount: _categoryBlocks.length,
              separatorBuilder: (context, index) => SizedBox(width: 8),
              itemBuilder: (context, index) => _buildTabButton(
                index,
                colors,
                label: _categoryBlocks[index].name,
                onTap: widget.onTap == null
                    ? null
                    : () => widget.onTap!(_categoryBlocks[index]),
              ),
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
          backgroundColor:
              widget.selectedTabIndex == index ? colors.primary : colors.surface,
          foregroundColor: colors.onSurface,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.smallBorderRadius),
          side: BorderSide(color: colors.outline),
        ),
        onPressed: onTap,
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
}
