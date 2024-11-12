import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/domain/services/mailing_service.dart';
import '/utils/get.dart';
import 'account_delete_dialog2.dart';

class AccountDeleteDialog1 extends StatefulWidget {
  const AccountDeleteDialog1({super.key});

  @override
  State<AccountDeleteDialog1> createState() => _AccountDeleteDialog1State();
}

class _AccountDeleteDialog1State extends State<AccountDeleteDialog1> {
  final _mailingService = Get.the<MailingService>();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete account'),
      content: Text('Are you sure you want to delete your account?'),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              setState(() => _loading = true);
              await _mailingService.sendAccountDeletionMail(user.email!, user.uid);
              setState(() => _loading = false);

              if (!context.mounted) return;
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (_) => AccountDeleteDialog2(
                  email: user.email!,
                  userId: user.uid,
                ),
              );
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Delete'),
              if (_loading) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CupertinoActivityIndicator(),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}
