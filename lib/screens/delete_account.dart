import 'package:flutter/material.dart';

import '/domain/services/language_constants.dart';
import '/utils/colors.dart';
import '/utils/firestore_helper.dart';
import '/utils/global_functions.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/custom_btn.dart';

class DeleteAccountScreen extends StatefulWidget {
  final String? email;
  const DeleteAccountScreen({super.key, this.email});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreen();
}

class _DeleteAccountScreen extends State<DeleteAccountScreen> with Translation {
  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isMobile) => AdaptiveAppBar(
          title: tr.deleteAccount,
        ),
        body: (context, isMobile) => ListView(
          children: [
            SizedBox(
              height: 50,
            ),
            Text(
              tr.deleteAccountMessage,
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 18),
            ),
            Text(
              tr.deleteAccountDescription,
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(
              height: 24,
            ),
            CustomButton(
                title: tr.deleteAccount,
                onPress: () async {
                  bool check = await deleteUserAccount();
                  if (check) {
                    logout(context);
                  }
                  Navigator.pop(context);
                },
                color: Colors.white,
                textColor: textColor)
          ],
        ),
      );
}
