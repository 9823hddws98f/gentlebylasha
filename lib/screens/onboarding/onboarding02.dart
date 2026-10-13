import 'package:flutter/material.dart';
import 'package:gentle/l10n/app_localizations.dart';

import '/domain/blocs/user/user_bloc.dart';
import '/domain/services/language_cubit.dart';
import '/helper/global_functions.dart';
import '/utils/get.dart';
import '/utils/tx_button.dart';

class OnBoarding02Screen extends StatefulWidget {
  final VoidCallback onSubmit;

  const OnBoarding02Screen({super.key, required this.onSubmit});

  @override
  State<OnBoarding02Screen> createState() => _OnBoarding02ScreenState();
}

class _OnBoarding02ScreenState extends State<OnBoarding02Screen> with Translation {
  /// Saved in the profile as these English values, whatever the app language.
  static const _options = [
    'Billboard',
    'App Store or Google',
    'TV Ad',
    'Therapist or health professional',
    'My employer',
    'Social media or online Ad',
    'Friend or family',
    'Article or blog',
    'Podcast Ad',
    'Other'
  ];

  static String _label(AppLocalizations tr, String option) => switch (option) {
        'Billboard' => tr.heardFromBillboard,
        'App Store or Google' => tr.heardFromAppStore,
        'TV Ad' => tr.heardFromTvAd,
        'Therapist or health professional' => tr.heardFromTherapist,
        'My employer' => tr.heardFromEmployer,
        'Social media or online Ad' => tr.heardFromSocialMedia,
        'Friend or family' => tr.heardFromFriend,
        'Article or blog' => tr.heardFromArticle,
        'Podcast Ad' => tr.heardFromPodcast,
        'Other' => tr.heardFromOther,
        _ => option,
      };

  String? _selectedOption;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                tr.heardFromQuestion,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: RadioGroup<String>(
                groupValue: _selectedOption,
                onChanged: (value) => setState(() => _selectedOption = value),
                child: ListView.builder(
                  itemCount: _options.length,
                  itemBuilder: (context, index) => RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: _options[index],
                    title: Text(
                      _label(tr, _options[index]),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            TxButton.filled(
              label: Text(tr.continueText),
              onPressVoid: () {
                if (_selectedOption == null) {
                  showToast(tr.selectOptionFirst);
                } else {
                  final bloc = Get.the<UserBloc>();
                  bloc.add(
                    UserModified(
                      bloc.state.user.copyWith(heardFrom: _selectedOption!),
                    ),
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
