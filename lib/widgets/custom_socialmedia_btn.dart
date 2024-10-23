import 'package:flutter/material.dart';

class CustomSocialButton extends StatelessWidget {
  final String title;
  final void Function() onPress;
  final Color color;
  final Color textColor;
  final Icon icon;
  const CustomSocialButton(
      {super.key,
      required this.title,
      required this.onPress,
      required this.color,
      required this.textColor,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: color,
        foregroundColor: textColor,
      ),
      onPressed: onPress,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              title,
              style: TextStyle(color: textColor, fontSize: 18),
            ),
          )
        ],
      ),
    );
  }
}
