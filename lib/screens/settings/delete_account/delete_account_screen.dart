import 'package:flutter/material.dart';
import 'package:sleeptales/screens/settings/delete_account/dialog/account_delete_dialog1.dart';
import 'package:sleeptales/utils/enums.dart';
import 'package:sleeptales/utils/tx_button.dart';
import 'package:sleeptales/widgets/app_scaffold/bottom_panel_spacer.dart';

import '/domain/services/language_cubit.dart';
import '/utils/app_theme.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';

class DeleteAccountScreen extends StatelessWidget with Translation {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isMobile) => AdaptiveAppBar(
          title: tr.deleteAccount,
        ),
        body: (context, isMobile) => BottomPanelSpacer.padding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: AppTheme.sidePadding),
                  children: [
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
                  ],
                ),
              ),
              TxButton.filled(
                label: Text(tr.deleteAccount),
                onPressVoid: () => showDialog(
                  context: context,
                  builder: (context) => AccountDeleteDialog1(),
                ),
                color: RoleColor.danger,
              ),
              SizedBox(height: AppTheme.sidePadding),
            ],
          ),
        ),
      );
}
