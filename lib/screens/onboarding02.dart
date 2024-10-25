import 'package:flutter/material.dart';

import '/domain/blocs/user/user_bloc.dart';
import '/utils/get.dart';
import '/utils/global_functions.dart';
import '/utils/tx_button.dart';
import '../constants/language_constants.dart';

class OnBoarding02Screen extends StatefulWidget {
  final VoidCallback onSubmit;

  const OnBoarding02Screen({super.key, required this.onSubmit});

  @override
  State<OnBoarding02Screen> createState() => _OnBoarding02ScreenState();
}

class _OnBoarding02ScreenState extends State<OnBoarding02Screen> {
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
  Widget build(BuildContext context) {
    final tr = translation(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'How did you hear about Sleepytales?',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 30, 0, 20),
            child: Column(
              children: _options
                  .map(
                    (entry) => RadioListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: Colors.white,
                      title: Text(
                        entry,
                        style: TextStyle(fontSize: 18),
                      ),
                      value: entry,
                      groupValue: _selectedOption,
                      onChanged: (value) => setState(() {
                        _selectedOption = value;
                      }),
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(height: 24),
          TxButton.filled(
            label: Text(tr.continueText),
            onPressVoid: () {
              if (_selectedOption == null) {
                showToast("Please select a option first");
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
          )
        ],
      ),
    );
  }
}
