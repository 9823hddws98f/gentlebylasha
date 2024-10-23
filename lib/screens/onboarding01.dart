import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/language_constants.dart';
import '/widgets/custom_btn.dart';
import '../utils/colors.dart';
import '../utils/global_functions.dart';

class OnBoarding01Screen extends StatefulWidget {
  final Function() callback;
  final Function(List<int> options) setSelectedOptions;
  UserCredential userCredentials;
  OnBoarding01Screen(this.callback, this.userCredentials, this.setSelectedOptions,
      {super.key});

  @override
  State<OnBoarding01Screen> createState() => _OnBoarding01ScreenState();
}

class _OnBoarding01ScreenState extends State<OnBoarding01Screen> {
  final List<int> _selectedGoalsOptions = [];
  final ScrollController _controller = ScrollController();

  final List<String> _options = [
    'Reduce Anxiety',
    'Improve Performance',
    'Build Self Esteem',
    'Reduce Stress',
    'Better Sleep',
    'Increase Happiness',
    'Develop Gratitude',
  ];

  final List<String> _icons = [
    "images/icon_water.png",
    "images/icon_running.png",
    "images/icon_rock.png",
    "images/icon_sun.png",
    "images/icon_moon.png",
    "images/icon_smile.png",
    "images/icon_leaf.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          children: [
            Column(
              children: [
                Text(
                  '${translation(context).whatBringsYouToSleepytales}?',
                  style: TextStyle(fontSize: 22),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  translation(context).personalizeRecMessage,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 24, 0, 24),
              child: ListView.builder(
                controller: _controller,
                itemBuilder: (BuildContext, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedGoalsOptions.contains(index)) {
                            _selectedGoalsOptions.remove(index);
                          } else {
                            _selectedGoalsOptions.add(index);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: _selectedGoalsOptions.contains(index)
                                ? blueAccentColor
                                : lightBlueWithOpacity,
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        height: 56,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Image.asset(
                                  _icons[index],
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(
                                _options[index],
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: _options.length,
                shrinkWrap: true,
                padding: EdgeInsets.fromLTRB(5, 0, 5, 10),
                scrollDirection: Axis.vertical,
              ),
            ),
            //SizedBox(height: 20),
            // Positioned(
            //   left: 0,
            //   right: 0,
            //   bottom: 50,
            //   child:

            CustomButton(
                title: translation(context).continueText,
                onPress: () {
                  if (_selectedGoalsOptions.isEmpty) {
                    showToast("Please select goals first");
                  } else {
                    widget.setSelectedOptions(_selectedGoalsOptions);
                    widget.callback();
                  }
                },
                color: Colors.white,
                textColor: Colors.black),
            // ),
          ],
        ),
      ),
    ));
  }
}
