import 'package:flutter/material.dart';

import '../constants/language_constants.dart';

class AppValidators {
  static const _emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  static String? Function(String?) emailValidator(BuildContext context) => (value) {
        if (value?.isEmpty ?? true) {
          return translation().enterEmail;
        }
        if (!RegExp(_emailRegex).hasMatch(value!)) {
          return translation().enterValidEmail;
        }
        return null;
      };

  static String? Function(String?) passwordValidator(BuildContext context) => (value) {
        if (value?.isEmpty ?? true) {
          return translation().enterPassword;
        }
        if (value!.length < 6) {
          return translation().passwordCaracterLimit;
        }
        return null;
      };
}
