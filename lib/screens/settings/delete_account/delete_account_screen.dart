import 'package:flutter/material.dart';

import '/domain/services/language_cubit.dart';
import '/screens/settings/delete_account/dialog/account_delete_dialog1.dart';
import '/utils/app_theme.dart';
import '/utils/enums.dart';
import '/utils/modals.dart';
import '/utils/tx_button.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';

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
                onPressVoid: () => Modals.show(
                  context,
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
