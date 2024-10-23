import 'package:flutter/material.dart';

import 'colors.dart';

var textFieldStyle = TextStyle(color: Colors.white, fontSize: 16);
var headingTextStyle = TextStyle(fontSize: 18);

InputDecoration decorationInputStyle(String hint) {
  return InputDecoration(
    fillColor: lightBlueColor,
    filled: true,
    hintStyle: TextStyle(color: Color(0xFFFFFFFF).withValues(alpha: 0.5)),
    hintText: hint,
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: lightBlueColor, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: lightBlueColor, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: lightBlueColor, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.purple, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: lightBlueColor, width: 2),
      borderRadius: BorderRadius.circular(8),
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
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: lightBlueColor, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.purple, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: lightBlueColor, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
