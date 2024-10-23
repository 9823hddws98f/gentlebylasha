import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/utils/global_functions.dart';
import '/widgets/custom_btn.dart';

class OnBoarding02Screen extends StatefulWidget {
  Function() callback;
  Function(int selected) setSelectedOption;
  UserCredential userCredentials;
  OnBoarding02Screen(this.callback, this.userCredentials, this.setSelectedOption,
      {super.key});

  @override
  State<OnBoarding02Screen> createState() => _OnBoarding02ScreenState();
}

class _OnBoarding02ScreenState extends State<OnBoarding02Screen> {
  int? _selectedOption;
  final List<String> _options = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                    .asMap()
                    .entries
                    .map(
                      (entry) => RadioListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.white,
                        title: Text(
                          entry.value,
                          style: TextStyle(fontSize: 18),
                        ),
                        value: entry.key,
                        groupValue: _selectedOption,
                        onChanged: (value) {
                          setState(() {
                            _selectedOption = value;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            SizedBox(
              height: 20,
            ),

            // Positioned(
            //   left: 0,
            //   right: 0,
            //   bottom: 50,
            //     child:

            CustomButton(
                title: "Continue",
                onPress: () {
                  if (_selectedOption == null) {
                    showToast("Please select a option first");
                  } else {
                    widget.setSelectedOption(_selectedOption!);
                    widget.callback();
                  }
                },
                color: Colors.white,
                textColor: Colors.black)

            // )
          ],
        ),
      ),
    ));
  }
}
