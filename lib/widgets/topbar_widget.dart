import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sleeptales/utils/colors.dart';
import 'package:sleeptales/widgets/circle_icon_button.dart';

import '../utils/styles.dart';

class TopBar extends StatelessWidget {
  final String heading;
  final void Function() onPress;
  const TopBar({Key? key, required this.heading, required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // if(Platform.isIOS)
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(padding: EdgeInsets.fromLTRB(16.w,0.h,0.w,5.h),
            child: CircleIconButton(icon: Icons.arrow_back_ios_new,onPressed: (){
              Navigator.pop(context);
            }, backgroundColor: transparentWhite, size: 32.h,iconSize: 20.h,)

          ),
        ),

        Align(
          alignment: Alignment.center,
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(padding:  EdgeInsets.fromLTRB(20.w,5.h,20.w,5.h),
                child: Text(heading,textAlign: TextAlign.center,style: headingTextStyle,),
              ),

            ],
          ),
        )

      ],
    );
  }
}
