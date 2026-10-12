import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '/domain/services/cloud_functions_service.dart';
import '/helper/global_functions.dart';
import '/utils/common_extensions.dart';
import '/utils/tx_button.dart';

/// Second step of account deletion: enter the emailed code.
/// The code is checked and the account deleted by the `deleteUser` function.
class AccountDeleteDialog2 extends StatefulWidget {
  const AccountDeleteDialog2({super.key, required this.email});

  final String email;

  @override
  State<AccountDeleteDialog2> createState() => _AccountDeleteDialog2State();
}

class _AccountDeleteDialog2State extends State<AccountDeleteDialog2> {
  final _codeController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Enter verification code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('The verification code has been sent to ${widget.email}.'),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(hintText: 'Enter code', errorText: _error),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Did not receive the code?'),
                InkWell(onTap: _resend, child: const Text('Resend')),
              ],
            ),
            Row(
              children: [
                const Spacer(),
                TxButton.outlined(
                  onPressVoid: () => Navigator.of(context).pop(),
                  label: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                TxButton.filled(onPress: _submit, label: const Text('Delete account')),
              ],
            ),
          ].interleaveWith(const SizedBox(height: 16)),
        ),
      );

  Future<void> _resend() async {
    try {
      await CloudFunctionsService.requestAccountDeletion();
      showToast('A new code has been sent.');
    } on FirebaseFunctionsException catch (e) {
      showToast(e.message == 'wait-before-resend'
          ? 'Please wait a minute before requesting a new code.'
          : 'Could not send the code. Please try again.');
    }
  }

  Future<bool> _submit() async {
    setState(() => _error = null);
    try {
      await CloudFunctionsService.deleteUser(_codeController.text);
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return false;
      setState(() => _error = switch (e.message) {
            'wrong-code' => 'This code is incorrect.',
            'expired' => 'This code has expired. Request a new one.',
            'too-many-attempts' => 'Too many attempts. Request a new code.',
            _ => 'Something went wrong. Please try again.',
          });
      return false;
    } catch (_) {
      if (mounted) setState(() => _error = 'Something went wrong. Please try again.');
      return false;
    }
    if (!mounted) return true;
    // The account is gone on the server; sign out locally and go to login.
    logout(context);
    return true;
  }
}
