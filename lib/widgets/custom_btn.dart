import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final void Function() onPress;
  final Color color;
  final Color textColor;
  const CustomButton({super.key, required this.title, required this.onPress,required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 48.h,
      child:ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: color,
            foregroundColor: textColor,
            shape:RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.h)),
            ),
          ),
          onPressed: onPress, child: Text(title,style: TextStyle(color: textColor, fontSize:18.sp),)) ,
    );
  }
}
