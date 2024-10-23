import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'colors.dart';

var textFieldStyle = TextStyle(color: Colors.white, fontSize: 16.sp);
var headingTextStyle = TextStyle(fontSize: 18.sp);

InputDecoration decorationInputStyle(String hint) {
  return InputDecoration(
    fillColor: lightBlueColor,
    filled: true,
    hintStyle: TextStyle(color: Color(0xFFFFFFFF).withValues(alpha: 0.5)),
    hintText: hint,
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: lightBlueColor, width: 2),
      borderRadius: BorderRadius.circular(8.h),
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: lightBlueColor, width: 2),
      borderRadius: BorderRadius.circular(8.h),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: lightBlueColor, width: 2),
      borderRadius: BorderRadius.circular(8.h),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.purple, width: 2),
      borderRadius: BorderRadius.circular(8.h),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: lightBlueColor, width: 2),
      borderRadius: BorderRadius.circular(8.h),
    ),
  );
}

InputDecoration decorationPasswordHintStyle(String hint, String iconPath, Widget icon) {
  return InputDecoration(
    hintStyle: textFieldStyle,
    suffixIcon: icon,
    fillColor: lightBlueColor,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: lightBlueColor, width: 2),
      borderRadius: BorderRadius.circular(8.h),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: lightBlueColor, width: 2),
      borderRadius: BorderRadius.circular(8.h),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.h),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.purple, width: 2),
      borderRadius: BorderRadius.circular(8.h),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: lightBlueColor, width: 2),
      borderRadius: BorderRadius.circular(8.h),
    ),
  );
}
