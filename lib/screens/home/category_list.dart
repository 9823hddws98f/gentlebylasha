import 'package:flutter/material.dart';

import '/domain/models/category_block.dart';
import '/utils/app_theme.dart';
import '/utils/firestore_helper.dart';
import '/widgets/shimmerwidgets/shimmerize.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  late final Future<List<CategoryBlock>> _future;

  @override
  void initState() {
    super.initState();
    _future = getCategoryBlocks();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: 47,
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final items = snapshot.data as List<CategoryBlock>;
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (context, index) => SizedBox(width: 8),
                itemBuilder: (context, index) => _buildTabButton(
                  colors,
                  label: items[index].name,
                  onTap: () {
                    // TODO: open explore tab
                    // indexNotifier.value = index;
                    // indexNotifier.notifyListeners();
                  },
                ),
              );
            } else {
              return _buildShimmer();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTabButton(
    ColorScheme colors, {
    required String label,
    required VoidCallback onTap,
  }) =>
      FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: colors.surface,
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
