import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/screens/onboarding01.dart';
import '/screens/onboarding02.dart';
import '/screens/subscription.dart';
import '/utils/app_theme.dart';

class OnboardingBottomSheet extends StatefulWidget {
  final UserCredential userCredential;

  const OnboardingBottomSheet(this.userCredential, {super.key});

  @override
  State<OnboardingBottomSheet> createState() => _OnboardingBottomSheetState();
}

class _OnboardingBottomSheetState extends State<OnboardingBottomSheet> {
  List<int> _selectedGoalsOptions = [];
  int? _selectedOption;
  int _selectedPage = 1;

  setSelectedGoalsOptions(List<int> selectedGoalsOptions) => setState(() {
        _selectedGoalsOptions = selectedGoalsOptions;
      });

  setSelectedOptions(int selectedOption) => setState(() {
        _selectedOption = selectedOption;
      });

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
          child: switch (_selectedPage) {
            // 0 => SignupScreen(
            //     () => _navigateTo(1),
            //     setUserCredentials,
            //     widget.callBackLogin,
            //   ),
            1 => OnBoarding01Screen(
                () => _navigateTo(2),
                widget.userCredential,
                setSelectedGoalsOptions,
              ),
            2 => OnBoarding02Screen(
                () => _navigateTo(3),
                widget.userCredential,
                setSelectedOptions,
              ),
            _ => SubscriptionScreen(
                () => _navigateTo(3),
                widget.userCredential,
                _selectedGoalsOptions,
                _selectedOption,
              )
          },
        ),
      );

  void _navigateTo(int page) {
    setState(() {
      _selectedPage = page;
    });
  }
}
