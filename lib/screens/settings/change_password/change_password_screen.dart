import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/domain/blocs/authentication/auth_repository.dart';
import '/utils/app_theme.dart';
import '/utils/command_trigger.dart';
import '/utils/get.dart';
import '/utils/global_functions.dart';
import '/utils/tx_button.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';
import '/widgets/input/password_edit_text.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String? email;
  const ChangePasswordScreen({super.key, this.email});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreen();
}

class _ChangePasswordScreen extends State<ChangePasswordScreen> {
  final _auth = Get.the<AuthRepository>();

  final _formKey = GlobalKey<FormState>();
  final _trigger = ActionTrigger();

  String? _currentPass;
  String? _newPass;

  bool _isPasswordAccount = true;

  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _auth.isPasswordAccount().then((value) => setState(() => _isPasswordAccount = value));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: (context, isMobile) => AdaptiveAppBar(
        title: 'Change password',
      ),
      body: (context, isMobile) => BottomPanelSpacer.padding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                autovalidateMode: _dirty
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: ListView(
                  children: [
                    SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Current password:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    PasswordEditText(
                      onSaved: (value) => setState(() => _currentPass = value),
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 18),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'New password:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    PasswordEditText(
                      onFieldSubmitted: (value) => _trigger.trigger(),
                      onSaved: (value) => setState(() => _newPass = value),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: AppTheme.sidePadding),
              child: TxButton.filled(
                label: _isPasswordAccount ? Text('Update') : Text('Reset password'),
                trigger: _trigger,
                onSuccess: () => Navigator.pop(context),
                onPress: !_isPasswordAccount
                    ? null
                    : () async => _formKey.currentState!.validate()
                        ? await _changePassword()
                        : false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _changePassword() async {
    if (!_dirty) setState(() => _dirty = true);
    _formKey.currentState!.save();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      // Reauthenticate the user with their current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPass!,
      );
      // Reauthenticate needed for password change
      await user.reauthenticateWithCredential(credential);

      // Update the user's password
      await user.updatePassword(_newPass!);

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        showToast('Incorrect current password. Please try again.');
      } else {
        showToast('Failed to change password: $e');
      }
      return false;
    }
  }
}
