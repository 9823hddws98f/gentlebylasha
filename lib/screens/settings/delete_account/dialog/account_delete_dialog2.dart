import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/domain/services/account_deletion_service.dart';
import '/domain/services/mailing_service.dart';
import '/utils/common_extensions.dart';
import '/utils/get.dart';
import '/utils/modals.dart';
import '/utils/tx_button.dart';

// TODO: TEST
class AccountDeleteDialog2 extends StatefulWidget {
  const AccountDeleteDialog2({
    super.key,
    required this.email,
    required this.userId,
  });

  final String email;
  final String userId;

  @override
  State<AccountDeleteDialog2> createState() => _AccountDeleteDialog2State();
}

class _AccountDeleteDialog2State extends State<AccountDeleteDialog2> {
  final _mailingService = Get.the<MailingService>();
  final _accountDeletionService = Get.the<AccountDeletionService>();

  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Enter verification code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'The verification code has been sent to ${widget.email}.',
            ),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: 'Enter code',
                fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Did not receive the code?'),
                InkWell(
                  child: Text('Resend'),
                  onTap: () => _mailingService.sendAccountDeletionMail(
                    widget.email,
                    widget.userId,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Spacer(),
                TxButton.outlined(
                  onPressVoid: () => Navigator.of(context).pop(),
                  label: Text('Cancel'),
                ),
                const SizedBox(width: 8),
                TxButton.filled(
                  onPressVoid: _submit,
                  label: Text('Submit'),
                ),
              ],
            )
          ].interleaveWith(const SizedBox(height: 16)),
        ),
      );

  Future<void> _submit() async {
    if (await _accountDeletionService.verifyDeletionCode(
        widget.email, _codeController.text)) {
      try {
        await FirebaseAuth.instance.currentUser!.delete();
      } catch (e) {
        if (!mounted) return;
        await Modals.show(
          context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      // Optionally, navigate to a different screen or show a success message
    } else {
      if (!mounted) return;
      // Show error message
      Modals.show(
        context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Verification code is incorrect.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
