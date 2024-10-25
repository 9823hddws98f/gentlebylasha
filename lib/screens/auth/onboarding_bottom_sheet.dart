import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/screens/onboarding01.dart';
import '/screens/onboarding02.dart';
import '/screens/subscription/subscription.dart';
import '/utils/app_theme.dart';

class OnboardingBottomSheet extends StatefulWidget {
  final UserCredential userCredential;

  const OnboardingBottomSheet(this.userCredential, {super.key});

  @override
  State<OnboardingBottomSheet> createState() => _OnboardingBottomSheetState();
}

class _OnboardingBottomSheetState extends State<OnboardingBottomSheet> {
  int _selectedPage = 1;

  void _navigateTo(int page) => setState(() => _selectedPage = page);

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: Container(
          height: 750,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: AppTheme.largeBorderRadius.topLeft,
              topRight: AppTheme.largeBorderRadius.topRight,
            ),
          ),
          child:
              // TODO: Add page transition switcher fadethrough
              switch (_selectedPage) {
            1 => OnBoarding01Screen(
                onSubmit: () => _navigateTo(2),
              ),
            2 => OnBoarding02Screen(
                onSubmit: () => _navigateTo(3),
              ),
            _ => SubscriptionScreen()
          },
        ),
      );
}
