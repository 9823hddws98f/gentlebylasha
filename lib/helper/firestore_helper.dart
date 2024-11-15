import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'global_functions.dart';

Future<bool> isEmailAndPasswordUserLoggedIn() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userInfo = await user.getIdTokenResult();
    return userInfo.signInProvider == "password";
  }
  return false;
}

// TODO: might be useful
Future<bool> updateUserEmailAndData(
    String newEmail, String newName, String password) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      // Reauthenticate the user
      AuthCredential credential =
          EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);

      // Update user email in Firebase Auth
      await user.updateEmail(newEmail);

      // Update user data in Firestore
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userRef.update({
        'email': newEmail,
        'name': newName,
      });

      debugPrint('User email and data updated successfully.');
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        showToast('Wrong password provided.');
        return false;
      } else {
        debugPrint("Error auth $e");
        return false;
      }
    } catch (e) {
      debugPrint("Error auth $e");
      return false;
    }
  } else {
    showToast('User is not logged in.');
    return false;
  }
}
