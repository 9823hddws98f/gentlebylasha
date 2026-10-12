import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Talks to the purchase Cloud Functions. The server checks every purchase
/// with Apple, Google or Stripe and updates `subscriptions/{uid}`.
class PurchasesApi {
  static final PurchasesApi instance = PurchasesApi._();

  PurchasesApi._();

  /// Must match `setGlobalOptions({region})` in functions/src/index.ts.
  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  /// Sends a store purchase to the server for verification.
  Future<void> verifyPurchase(PurchaseDetails details) async {
    final isIos = Platform.isIOS || Platform.isMacOS;
    await _functions.httpsCallable('verifyPurchase').call({
      'platform': isIos ? 'ios' : 'android',
      // Apple: a transaction id of the subscription. Google: the purchase token.
      'purchaseId': isIos
          ? details.purchaseID
          : details.verificationData.serverVerificationData,
    });
  }

  /// Stripe Checkout URL for the web. [plan] is 'monthly' or 'yearly'.
  Future<Uri> checkoutUrl(String plan) async {
    final result =
        await _functions.httpsCallable('createCheckoutSession').call({'plan': plan});
    return Uri.parse(result.data['url'] as String);
  }

  /// Stripe customer portal URL (change card, switch plan, cancel).
  Future<Uri> portalUrl() async {
    final result = await _functions.httpsCallable('createPortalSession').call();
    return Uri.parse(result.data['url'] as String);
  }
}
