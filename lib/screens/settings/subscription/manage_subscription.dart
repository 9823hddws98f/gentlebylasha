import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '/domain/cubits/entitlement_cubit.dart';
import '/domain/services/language_cubit.dart';
import '/helper/global_functions.dart';
import '/utils/app_theme.dart';
import '/utils/enums.dart';
import '/utils/get.dart';
import '/utils/tx_button.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';
import 'redeem_code_screen.dart';
import 'subscribe_modal.dart';

class ManageSubscriptionScreen extends StatelessWidget with Translation {
  final String? email;

  ManageSubscriptionScreen({super.key, this.email});

  String _statusText(BuildContext context, Entitlement e) {
    if (!e.isPremium) return tr.noSubscription;
    if (e.expiresAt == null) return tr.premiumLifetime;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return tr.premiumUntil(DateFormat.yMMMMd(locale).format(e.expiresAt!));
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (text, isMobile) => AdaptiveAppBar(title: tr.manageSubscription),
        body: (context, isMobile) => BottomPanelSpacer.padding(
          child: BlocBuilder<EntitlementCubit, Entitlement>(
            bloc: Get.the<EntitlementCubit>(),
            builder: (context, entitlement) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppTheme.sidePadding),
                    children: [
                      Center(
                        child: Text(
                          _statusText(context, entitlement),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!entitlement.isPremium) ...[
                  TxButton.filled(
                    label: const Text('Purchase'),
                    color: RoleColor.mono,
                    onPressVoid: () => SubscribeModal.show(context),
                  ),
                  const SizedBox(height: 8),
                  TxButton.text(
                    label: Text(tr.haveACode),
                    onPressVoid: () => pushName(context, const RedeemCodeScreen()),
                  ),
                ],
                const SizedBox(height: AppTheme.sidePadding),
              ],
            ),
          ),
        ),
      );
}
