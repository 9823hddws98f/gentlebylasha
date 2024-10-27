import 'package:flutter/material.dart';

import '/constants/assets.dart';
import '/domain/blocs/user/user_bloc.dart';
import '/domain/services/language_constants.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/utils/global_functions.dart';
import '/utils/tx_button.dart';

class OnBoarding01Screen extends StatefulWidget {
  final VoidCallback onSubmit;

  const OnBoarding01Screen({super.key, required this.onSubmit});

  @override
  State<OnBoarding01Screen> createState() => _OnBoarding01ScreenState();
}

class _OnBoarding01ScreenState extends State<OnBoarding01Screen> with Translation {
  static const _options = [
    'Reduce Anxiety',
    'Improve Performance',
    'Build Self Esteem',
    'Reduce Stress',
    'Better Sleep',
    'Increase Happiness',
    'Develop Gratitude',
  ];

  // TODO: Move these to assets
  static const _icons = [
    Assets.iconWater,
    Assets.iconRunning,
    Assets.iconRock,
    Assets.iconSun,
    Assets.iconMoon,
    Assets.iconSmile,
    Assets.iconLeaf,
  ];

  final List<String> options = [];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.whatBringsYouToSleepytales,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _options.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) => InkWell(
                borderRadius: AppTheme.smallBorderRadius,
                onTap: () => setState(() {
                  if (options.contains(_options[index])) {
                    options.remove(_options[index]);
                  } else {
                    options.add(_options[index]);
                  }
                }),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: AppTheme.smallBorderRadius,
                    color: options.contains(_options[index])
                        ? colors.surfaceContainerHighest
                        : colors.surfaceContainerLowest,
                  ),
                  height: 56,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Image.asset(
                          _icons[index],
                          color: colors.onSurface,
                          height: 24,
                          width: 24,
                        ),
                        SizedBox(width: 16),
                        Text(
                          _options[index],
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TxButton.filled(
            label: Text(tr.continueText),
            showSuccess: false,
            onPressVoid: () {
              if (options.isEmpty) {
                showToast('Please select goals first');
              } else {
                final bloc = Get.the<UserBloc>();
                bloc.add(
                  UserModified(bloc.state.user.copyWith(goals: options.toList())),
                );
                widget.onSubmit();
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
