import 'package:flutter/material.dart';

import '/helper/global_functions.dart';
import '/utils/app_theme.dart';
import '/widgets/shimmerize.dart';

class BlockHeader extends StatelessWidget {
  const BlockHeader({super.key, required this.title, this.seeAll});

  final String title;
  final Widget? seeAll;

  static const _padding = EdgeInsets.fromLTRB(
    AppTheme.sidePadding,
    8,
    AppTheme.sidePadding,
    16,
  );

  @override
  Widget build(BuildContext context) => Padding(
        padding: _padding,
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
        padding: EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: Row(
          children: [
            Shimmerize(
              child: Card(
                child: SizedBox(
                  width: 100,
                  height: 20,
                ),
              ),
            ),
            Spacer(),
            Shimmerize(
              child: Card(
                child: SizedBox(
                  width: 40,
                  height: 20,
                ),
              ),
            )
          ],
        ),
      );
}
