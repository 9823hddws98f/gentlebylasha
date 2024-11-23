import 'package:flutter/material.dart';

import '/utils/app_theme.dart';
import '/utils/enums.dart';
import '/utils/tx_button.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';
import 'subscribe_modal.dart';

class ManageSubscriptionScreen extends StatelessWidget {
  final String? email;

  const ManageSubscriptionScreen({super.key, this.email});

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (text, isMobile) => AdaptiveAppBar(
          title: 'Manage Subscription',
        ),
        body: (context, isMobile) => BottomPanelSpacer.padding(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppTheme.sidePadding),
                  children: [
                    Center(
                      child: Text(
                        'You subscribed on IOS',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TxButton.filled(
                label: Text('Purchase'),
                color: RoleColor.mono,
                onPressVoid: () => SubscribeModal.show(context),
              ),
              const SizedBox(height: AppTheme.sidePadding),
            ],
          ),
        ),
      );
}
