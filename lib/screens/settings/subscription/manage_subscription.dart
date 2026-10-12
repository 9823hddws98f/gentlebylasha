import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '/domain/cubits/entitlement_cubit.dart';
import '/domain/cubits/in_app_purchases/iap_service.dart';
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

  static const _sourceName = {'stripe': 'web', 'apple': 'App Store', 'google': 'Google Play'};

  /// Where the user can change or cancel their subscription, per source.
  /// Codes and manual grants have nothing to manage.
  Future<Uri>? _manageUrl(String? source) => switch (source) {
        'stripe' => PurchasesApi.instance.portalUrl(),
        'apple' => Future.value(Uri.parse('https://apps.apple.com/account/subscriptions')),
        'google' => Future.value(Uri.parse(
            'https://play.google.com/store/account/subscriptions?package=com.mezz.gentle')),
        _ => null,
      };

  Future<void> _openManage(String source) async {
    try {
      final url = await _manageUrl(source);
      if (url != null) await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      showToast(tr.somethingWentWrong);
    }
  }

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
                for (final source in entitlement.billingSources)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TxButton.outlined(
                      label: Text(entitlement.billingSources.length > 1
                          ? '${tr.manageInStore} (${_sourceName[source]})'
                          : tr.manageInStore),
                      showSuccess: false,
                      onPressVoid: () => _openManage(source),
                    ),
                  ),
                if (!entitlement.isPremium) ...[
                  TxButton.filled(
                    label: Text(tr.subscribe),
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
