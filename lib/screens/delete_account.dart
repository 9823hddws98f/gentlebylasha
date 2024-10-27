import 'package:flutter/material.dart';

import '/utils/colors.dart';
import '/utils/firestore_helper.dart';
import '/utils/global_functions.dart';
import '/widgets/custom_btn.dart';
import '/widgets/topbar_widget.dart';
import '../domain/services/language_constants.dart';

class DeleteAccountScreen extends StatefulWidget {
  final String? email;
  const DeleteAccountScreen({super.key, this.email});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreen();
}

class _DeleteAccountScreen extends State<DeleteAccountScreen> with Translation {
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
                          heading: tr.deleteAccount,
                          onPress: () {
                            Navigator.pop(context);
                          }),
                      SizedBox(
                        height: 50,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          tr.deleteAccountMessage,
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          tr.deleteAccountDescription,
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: CustomButton(
                            title: tr.deleteAccount,
                            onPress: () async {
                              showLoaderDialog(context, "Deleting account...");
                              bool check = await deleteUserAccount();
                              if (check) {
                                logout(context);
                              }
                              Navigator.pop(context);
                            },
                            color: Colors.white,
                            textColor: textColor),
                      )
                    ],
                  ))),
        ),
      ),
    );
  }
}
