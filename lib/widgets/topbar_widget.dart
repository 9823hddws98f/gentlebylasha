import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/styles.dart';
import '/utils/colors.dart';
import '/widgets/circle_icon_button.dart';

class TopBar extends StatelessWidget {
  final String heading;
  final void Function() onPress;
  const TopBar({super.key, required this.heading, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // if(Platform.isIOS)
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0.h, 0.w, 5.h),
              child: CircleIconButton(
                icon: Icons.arrow_back_ios_new,
                onPressed: () {
                  Navigator.pop(context);
                },
                backgroundColor: transparentWhite,
                size: 32.h,
                iconSize: 20.h,
              )),
        ),

        Align(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 5.h),
                child: Text(
                  heading,
                  textAlign: TextAlign.center,
                  style: headingTextStyle,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
