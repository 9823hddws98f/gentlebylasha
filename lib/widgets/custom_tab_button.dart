import 'package:flutter/material.dart';

class CustomTabButton extends StatelessWidget {
  final String title;
  final void Function() onPress;
  final Color color;
  final Color textColor;
  const CustomTabButton(
      {super.key,
      required this.title,
      required this.onPress,
      required this.color,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: 40,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: color,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          onPressed: onPress,
          child: Text(
            title,
            style: TextStyle(color: textColor, fontSize: 14),
          )),
    );
  }
}
