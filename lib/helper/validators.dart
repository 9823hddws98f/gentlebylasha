import '/domain/services/language_cubit.dart';
import '/utils/get.dart';

class AppValidators {
  static const _emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static final tr = Get.the<LanguageCubit>().translation;

  static String? Function(String?) emailValidator = (value) {
    if (value?.isEmpty ?? true) {
      return tr.enterEmail;
    }
    if (!RegExp(_emailRegex).hasMatch(value!)) {
      return tr.enterValidEmail;
    }
    return null;
  };

  static String? Function(String?) passwordValidator = (value) {
    if (value?.isEmpty ?? true) {
      return tr.enterPassword;
    }
    if (value!.length < 6) {
      return tr.passwordCaracterLimit;
    }
    return null;
  };
}
