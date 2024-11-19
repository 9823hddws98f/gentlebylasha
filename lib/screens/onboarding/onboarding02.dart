import 'package:flutter/material.dart';

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
                'How did you hear about Sleepytales?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _options.length,
                itemBuilder: (context, index) => RadioListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: _options[index],
                  groupValue: _selectedOption,
                  title: Text(
                    _options[index],
                    style: TextStyle(fontSize: 16),
                  ),
                  onChanged: (value) => setState(() => _selectedOption = value),
                ),
              ),
            ),
            SizedBox(height: 12),
            TxButton.filled(
              label: Text(tr.continueText),
              onPressVoid: () {
                if (_selectedOption == null) {
                  showToast('Please select a option first');
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
