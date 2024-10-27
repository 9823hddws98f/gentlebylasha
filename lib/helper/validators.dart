import 'package:flutter/material.dart';
import 'package:sleeptales/utils/get.dart';

import '/domain/services/language_constants.dart';

class AppValidators {
  static const _emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static final tr = Get.the<TranslationService>().translation();

  static String? Function(String?) emailValidator(BuildContext context) => (value) {
        if (value?.isEmpty ?? true) {
          return tr.enterEmail;
        }
        if (!RegExp(_emailRegex).hasMatch(value!)) {
          return tr.enterValidEmail;
        }
        return null;
      };

  static String? Function(String?) passwordValidator(BuildContext context) => (value) {
        if (value?.isEmpty ?? true) {
          return tr.enterPassword;
        }
        if (value!.length < 6) {
          return tr.passwordCaracterLimit;
        }
        return null;
      };
}
