import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '/domain/cubits/entitlement_cubit.dart';
import '/domain/cubits/in_app_purchases/iap_cubit.dart';
import '/domain/cubits/in_app_purchases/iap_service.dart';
import '/domain/cubits/in_app_purchases/product.dart';
import '/domain/services/language_cubit.dart';
import '/helper/global_functions.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/utils/modals.dart';
import '/utils/tx_button.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';
import 'redeem_code_screen.dart';

/// Paywall. Mobile sells through the App Store / Google Play, the web through
/// Stripe Checkout. Closes itself once premium becomes active.
class SubscribeModal extends StatefulWidget {
  const SubscribeModal({super.key, this.scrollController});

  final ScrollController? scrollController;

  static Future<void> show(BuildContext context) => Modals.showModal(
        context,
        initialSize: 1,
        maxSize: 1,
        minSize: 1,
        builder: (context, scrollController) => SubscribeModal(
          scrollController: scrollController,
        ),
      );

  @override
  State<SubscribeModal> createState() => _SubscribeModalState();
}

class _SubscribeModalState extends State<SubscribeModal> with Translation {
  final _iap = Get.the<IAPCubit>();
  final _entitlement = Get.the<EntitlementCubit>();

  /// Selected plan; yearly first since it is the better deal.
  bool _yearly = true;
  bool _webBusy = false;
  String? _webError;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) _iap.loadProducts();
  }

  Future<void> _subscribe(List<PurchasableProduct> products) async {
    if (kIsWeb) return _subscribeWeb();
    final product =
        products.where((p) => p.isYearly == _yearly).firstOrNull ?? products.firstOrNull;
    if (product != null) await _iap.purchaseProduct(product.productDetails);
  }

  Future<void> _subscribeWeb() async {
    setState(() {
      _webBusy = true;
      _webError = null;
    });
    try {
      final url = await PurchasesApi.instance.checkoutUrl(_yearly ? 'yearly' : 'monthly');
      await launchUrl(url, webOnlyWindowName: '_self');
    } catch (_) {
      if (mounted) setState(() => _webError = tr.purchaseFailed);
    } finally {
      if (mounted) setState(() => _webBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return BlocListener<EntitlementCubit, Entitlement>(
      bloc: _entitlement,
      listenWhen: (before, now) => !before.isPremium && now.isPremium,
      listener: (context, _) {
        showToast(tr.premiumWelcome);
        Navigator.of(context).maybePop();
      },
      child: BlocBuilder<IAPCubit, IAPState>(
        bloc: _iap,
        builder: (context, state) {
          final busy = kIsWeb ? _webBusy : state.busy;
          final error = kIsWeb
              ? _webError
              : switch (state.error) {
                  IAPError.purchaseFailed => tr.purchaseFailed,
                  IAPError.verificationFailed => tr.verificationFailed,
                  IAPError.otherAccount => tr.purchaseOtherAccount,
                  IAPError.none =>
                    state.storeAvailable == false ? tr.storeUnavailable : null,
                };
          final canBuy = kIsWeb || state.loaded;

          return BottomPanelSpacer.padding(
            child: Material(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ListView(
                        controller: widget.scrollController,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            tr.unlockGentle,
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          _benefit(colors, tr.benefitAllContent),
                          _benefit(colors, tr.benefitNewContent),
                          _benefit(colors, tr.benefitCancel),
                          const SizedBox(height: 24),
                          _plan(colors, yearly: true, price: _priceOf(state, yearly: true)),
                          const SizedBox(height: 12),
                          _plan(colors, yearly: false, price: _priceOf(state, yearly: false)),
                          if (error != null) ...[
                            const SizedBox(height: 16),
                            Text(error, style: TextStyle(color: colors.error)),
                          ],
                        ],
                      ),
                    ),
                    TxButton.filled(
                      label: busy
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(tr.subscribe),
                      showSuccess: false,
                      onPressVoid: busy || !canBuy ? null : () => _subscribe(state.products),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        if (!kIsWeb)
                          TxButton.text(
                            label: Text(tr.restorePurchases),
                            showSuccess: false,
                            onPressVoid: busy ? null : _iap.restorePurchases,
                          ),
                        TxButton.text(
                          label: Text(tr.haveACode),
                          showSuccess: false,
                          onPressVoid: () {
                            // Grab the navigator first: this modal's context is gone after pop.
                            final navigator = Navigator.of(context);
                            navigator.pop();
                            navigator.push(
                              MaterialPageRoute(builder: (_) => const RedeemCodeScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Store price on mobile; on the web Stripe Checkout shows the price.
  String? _priceOf(IAPState state, {required bool yearly}) =>
      state.products.where((p) => p.isYearly == yearly).firstOrNull?.price;

  Widget _plan(ColorScheme colors, {required bool yearly, String? price}) {
    final selected = _yearly == yearly;
    return Material(
      color: selected ? colors.primary.withAlpha(30) : colors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: AppTheme.smallBorderRadius,
        side: BorderSide(
          color: selected ? colors.primary : colors.outline,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: AppTheme.smallBorderRadius,
        onTap: () => setState(() => _yearly = yearly),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  yearly ? tr.planYearly : tr.planMonthly,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              if (price != null)
                Text.rich(TextSpan(children: [
                  TextSpan(
                    text: price,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: ' ${yearly ? tr.perYear : tr.perMonth}',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefit(ColorScheme colors, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle, color: colors.primary),
              child: const Icon(Icons.check, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(text)),
          ],
        ),
      );
}
