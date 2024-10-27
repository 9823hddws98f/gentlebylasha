import 'package:flutter/material.dart';

import '/utils/app_theme.dart';
import '/utils/global_functions.dart';
import '/widgets/shimmerwidgets/shimmerize.dart';

class BlockHeader extends StatelessWidget {
  const BlockHeader({
    super.key,
    required this.title,
    this.seeAll,
  });

  final String title;
  final Widget? seeAll;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.sidePadding,
          vertical: 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (seeAll != null)
              GestureDetector(
                onTap: () => pushName(context, seeAll!),
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              )
          ],
        ),
      );

  static Widget shimmer() => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.sidePadding,
          vertical: 16,
        ),
        child: Row(
          children: [
            Shimmerize(
              child: Card(
                child: SizedBox(
                  width: 100,
                  height: 30,
                ),
              ),
            ),
            Spacer(),
            Shimmerize(
              child: Card(
                child: SizedBox(
                  width: 70,
                  height: 30,
                ),
              ),
            )
          ],
        ),
      );
}
