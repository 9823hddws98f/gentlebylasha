import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/widgets/input/password_edit_text.dart';
import '/widgets/topbar_widget.dart';
import '../utils/global_functions.dart';
import '../widgets/custom_btn.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String? email;
  const ChangePasswordScreen({super.key, this.email});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreen();
}

class _ChangePasswordScreen extends State<ChangePasswordScreen> {
  bool newPassShow = true;
  bool curPassShow = true;
  String? currentPass;
  String? newPass;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TopBar(
                          heading: "Change password",
                          onPress: () {
                            Navigator.pop(context);
                          }),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 30, 0, 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Current password",
                                    style: TextStyle(fontSize: 16)),
                              ),
                            ),
                            PasswordEditText(
                              onSaved: (value) => setState(() => currentPass = value),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 30, 0, 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child:
                                    Text("New password", style: TextStyle(fontSize: 16)),
                              ),
                            ),
                            PasswordEditText(
                              onSaved: (value) => setState(() => newPass = value),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: CustomButton(
                            onPress: () {
                              if (formKey.currentState!.validate()) {
                                showLoaderDialog(context, "Updating password...");
                                changePassword(newPass!, currentPass!);
                              } else {
                                showToast("Invalid input");
                              }
                            },
                            title: "Update",
                            color: Colors.white,
                            textColor: Colors.black,
                          )),
                      SizedBox(
                        height: 180,
                      )
                    ],
                  ))),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Dispose fields and cancel listeners

    currentPass = "";
    newPass = "";
    super.dispose();
  }

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
        currentPass = '';
        newPass = '';
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
