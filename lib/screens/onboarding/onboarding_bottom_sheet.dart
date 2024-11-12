import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '/screens/subscription/subscription.dart';
import '/utils/app_theme.dart';
import '/utils/modals.dart';
import '/widgets/shared_axis_switcher.dart';
import 'onboarding01.dart';
import 'onboarding02.dart';

class OnboardingBottomSheet extends StatefulWidget {
  const OnboardingBottomSheet({super.key});

  static Future<void> show(BuildContext context) => Modals.show(
        context,
        enableDrag: false,
        scrollable: false,
        useSafeArea: true,
        isDismissible: false,
        initialSize: 0.9,
        maxSize: 0.9,
        minSize: 0.9,
        showDragHandle: false,
        builder: (context, scrollController) => OnboardingBottomSheet(),
      );

  @override
  State<OnboardingBottomSheet> createState() => _OnboardingBottomSheetState();
}

class _OnboardingBottomSheetState extends State<OnboardingBottomSheet> {
  int _selectedPage = 1;

  void _navigateTo(int page) => setState(() => _selectedPage = page);

  @override
  Widget build(BuildContext context) => Material(
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.only(
          topLeft: AppTheme.largeBorderRadius.topLeft,
          topRight: AppTheme.largeBorderRadius.topRight,
        ),
        child: SharedAxisSwitcher(
          transitionType: SharedAxisTransitionType.horizontal,
          child: switch (_selectedPage) {
            1 => OnBoarding01Screen(onSubmit: () => _navigateTo(2)),
            2 => OnBoarding02Screen(onSubmit: () => _navigateTo(3)),
            _ => SubscriptionScreen()
          },
        ),
      );
}
