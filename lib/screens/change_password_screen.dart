import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/input/password_edit_text.dart';
import '/utils/global_functions.dart';
import '/widgets/custom_btn.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String? email;
  const ChangePasswordScreen({super.key, this.email});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreen();
}

class _ChangePasswordScreen extends State<ChangePasswordScreen> {
  String? _currentPass;
  String? _newPass;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: (context, isMobile) => AdaptiveAppBar(
        title: 'Change password',
      ),
      body: (context, isMobile) => ListView(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Current password', style: TextStyle(fontSize: 16)),
                  ),
                ),
                PasswordEditText(
                  onSaved: (value) => setState(() => _currentPass = value),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 30, 0, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('New password', style: TextStyle(fontSize: 16)),
                  ),
                ),
                PasswordEditText(
                  onSaved: (value) => setState(() => _newPass = value),
                ),
              ],
            ),
          ),
          Padding(
              padding: EdgeInsets.only(top: 50),
              child: CustomButton(
                onPress: () {
                  if (_formKey.currentState!.validate()) {
                    showLoaderDialog(context, "Updating password...");
                    changePassword(_newPass!, _currentPass!);
                  } else {
                    showToast("Invalid input");
                  }
                },
                title: 'Update',
                color: Colors.white,
                textColor: Colors.black,
              )),
          SizedBox(
            height: 180,
          )
        ],
      ),
    );
  }

  // TODO: CHANGE TO USE AUTH REPO
  Future<void> changePassword(String newPassword, String oldPassword) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        user.providerData.any((provider) => provider.providerId == 'password')) {
      // user is signed in with email and password, so they can change their password
      try {
        // reauthenticate the user with their current password
        AuthCredential credential =
            EmailAuthProvider.credential(email: user.email!, password: oldPassword);
        await user.reauthenticateWithCredential(credential);

        // update the user's password
        await user.updatePassword(newPassword);
        showToast("Password changed successfully");
        _currentPass = '';
        _newPass = '';
        setState(() {});
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          showToast("Incorrect current password. Please try again.");
          Navigator.pop(context);
        } else {
          showToast("Failed to change password: $e");
          Navigator.pop(context);
        }
        // handle error
      }
    } else {
      // user is signed in with a third-party provider, so they cannot change their password
      showToast("Cannot change password for user signed in with a third-party provider");
      Navigator.pop(context);
    }
  }
}
