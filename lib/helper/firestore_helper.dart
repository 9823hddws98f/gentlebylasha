import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '/domain/services/language_cubit.dart';
import '/utils/get.dart';
import 'auth_errors.dart';
import 'global_functions.dart';

Future<bool> isEmailAndPasswordUserLoggedIn() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userInfo = await user.getIdTokenResult();
    return userInfo.signInProvider == 'password';
  }
  return false;
}

/// Changes the name right away and starts an email change. Firebase only
/// switches the sign-in address after the user opens the link it mails to
/// [newEmail]; the profile picks up the new address after that (UserBloc).
Future<bool> updateUserEmailAndData(String newEmail, String newName, String password) async {
  final tr = Get.the<LanguageCubit>().translation;
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || user.email == null) {
    showToast(tr.somethingWentWrong);
    return false;
  }
  try {
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: user.email!, password: password),
    );
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'name': newName});
    if (newEmail != user.email) {
      await user.verifyBeforeUpdateEmail(newEmail);
      showToast(tr.confirmNewEmail(newEmail));
    }
    return true;
  } on FirebaseAuthException catch (e) {
    showToast(
        authErrorMessage(e.code, tr, fallback: tr.somethingWentWrong) ?? tr.somethingWentWrong);
    return false;
  } catch (e) {
    debugPrint('Updating the profile failed: $e');
    showToast(tr.somethingWentWrong);
    return false;
  }
}
