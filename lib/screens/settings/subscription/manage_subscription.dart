import 'package:flutter/material.dart';
import 'package:sleeptales/utils/app_theme.dart';
import 'package:sleeptales/utils/enums.dart';
import 'package:sleeptales/utils/tx_button.dart';

import '/utils/common_extensions.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';

class ManageSubscriptionScreen extends StatelessWidget {
  final String? email;

  const ManageSubscriptionScreen({super.key, this.email});

  static const _data = '''
Your free trial began on August 9, 2021.
Your yearly subscription will begin on August 16, 2021.

However, if you’ve already stopped recurring payments through iTunes, then your access will lapse at that time, and you won’t be charged.

If you would like to stop recurring payments, you can do so here.Unfortunately, we’re unable to do so on your behalf.''';

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
                    Text(
                      _data,
                      textAlign: TextAlign.center,
                    ),
                  ].interleaveWith(const SizedBox(height: 16)),
                ),
              ),
              Center(
                child: Text(
                  'Questions?',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              TxButton.filled(
                label: Text('Visit help center'),
                color: RoleColor.mono,
                onPressVoid: () {},
              ),
              const SizedBox(height: AppTheme.sidePadding),
            ],
          ),
        ),
      );
}
