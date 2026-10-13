import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '/domain/services/cloud_functions_service.dart';
import '/domain/services/language_cubit.dart';
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

class _AccountDeleteDialog2State extends State<AccountDeleteDialog2> with Translation {
  final _codeController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(tr.enterVerificationCode),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(tr.verificationCodeSent(widget.email)),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(hintText: tr.enterCode, errorText: _error),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(tr.codeNotReceived),
                InkWell(onTap: _resend, child: Text(tr.resend)),
              ],
            ),
            Row(
              children: [
                const Spacer(),
                TxButton.outlined(
                  onPressVoid: () => Navigator.of(context).pop(),
                  label: Text(tr.cancel),
                ),
                const SizedBox(width: 8),
                TxButton.filled(onPress: _submit, label: Text(tr.deleteAccount)),
              ],
            ),
          ].interleaveWith(const SizedBox(height: 16)),
        ),
      );

  Future<void> _resend() async {
    try {
      await CloudFunctionsService.requestAccountDeletion();
      showToast(tr.newCodeSent);
    } on FirebaseFunctionsException catch (e) {
      showToast(e.message == 'wait-before-resend'
          ? tr.waitBeforeResend
          : tr.codeSendFailed);
    }
  }

  Future<bool> _submit() async {
    setState(() => _error = null);
    try {
      await CloudFunctionsService.deleteUser(_codeController.text);
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return false;
      setState(() => _error = switch (e.message) {
            'wrong-code' => tr.verificationCodeWrong,
            'expired' => tr.verificationCodeExpired,
            'too-many-attempts' => tr.verificationTooManyAttempts,
            _ => tr.somethingWentWrong,
          });
      return false;
    } catch (_) {
      if (mounted) setState(() => _error = tr.somethingWentWrong);
      return false;
    }
    if (!mounted) return true;
    // The account is gone on the server; sign out locally and go to login.
    logout(context);
    return true;
  }
}
