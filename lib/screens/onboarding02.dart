import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '/utils/global_functions.dart';
import '/widgets/custom_btn.dart';

class OnBoarding02Screen extends StatefulWidget {
  Function() callback;
  Function(int selected) setSelectedOption;
  UserCredential userCredentials;
  OnBoarding02Screen(this.callback, this.userCredentials, this.setSelectedOption, {super.key});

  @override
  _OnBoarding02ScreenState createState() => _OnBoarding02ScreenState();
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
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Text(
                'How did you hear about Sleepytales?',
                style: TextStyle(fontSize: 18.sp),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(0, 30.h, 0, 20.h),
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
                          style: TextStyle(fontSize: 18.sp),
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
              height: 20.h,
            ),

            // Positioned(
            //   left: 0,
            //   right: 0,
            //   bottom: 50.h,
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
