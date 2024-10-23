import 'package:flutter/material.dart';

import '/language_constants.dart';

class AppValidators {
  static const _emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const _passwordRegex = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$';

  static String? Function(String?) emailValidator(BuildContext context) => (value) {
        if (value?.isEmpty ?? true) {
          return translation(context).enterEmail;
        }
        if (!RegExp(_emailRegex).hasMatch(value!)) {
          return translation(context).enterValidEmail;
        }
        return null;
      };

  static String? Function(String?) passwordValidator(BuildContext context) => (value) {
        if (value?.isEmpty ?? true) {
          return translation(context).enterPassword;
        }
        if (!RegExp(_passwordRegex).hasMatch(value!)) {
          return translation(context).passwordCaracterLimit;
        }
        return null;
      };
}
