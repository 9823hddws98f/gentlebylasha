import 'package:flutter/material.dart';

class LoginFooter extends StatelessWidget {
  final String sentenceText;
  final String loginSingUpText;
  final Function() onPress;
  MainAxisAlignment alignment;
  LoginFooter(
      {super.key,
      required this.sentenceText,
      required this.loginSingUpText,
      required this.alignment,
      required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        Text(
          sentenceText,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        TextButton(
          onPressed: onPress,
          child: Text(
            loginSingUpText,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              decoration: TextDecoration.underline,
            ),
          ),
        )
      ],
    );
  }
}
