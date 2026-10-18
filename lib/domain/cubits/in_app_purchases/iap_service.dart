import 'dart:convert';
import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:intl/intl.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

/// A store transaction as the server wants it, plus the subscription it
/// belongs to.
class StorePurchase {
  /// 'ios' or 'android' (verifyPurchase contract).
  final String platform;

  /// Apple: a transaction id of the subscription. Google: the purchase token.
  final String purchaseId;

  /// The same for every transaction of one subscription (renewals, restores),
  /// so a restore that delivers many transactions is verified once.
  final String subscriptionKey;

  const StorePurchase({
    required this.platform,
    required this.purchaseId,
    required this.subscriptionKey,
  });

  /// Reads [details] from the App Store (StoreKit 1 or 2) or Google Play;
  /// null when it has no usable id.
  ///
  /// The app runs on StoreKit 2 (the default of in_app_purchase_storekit
  /// 0.4+): its purchaseID is the transaction id, which changes with every
  /// renewal, and the original transaction id is in the transaction JSON.
  /// StoreKit 1 restores carry a new local id; Apple knows the original one.
  static StorePurchase? from(PurchaseDetails details) {
    if (details.verificationData.source == 'google_play') {
      final token = details.verificationData.serverVerificationData;
      if (token.isEmpty) return null;
      return StorePurchase(
          platform: 'android', purchaseId: token, subscriptionKey: 'android:$token');
    }
    final original = details is AppStorePurchaseDetails
        ? details.skPaymentTransaction.originalTransaction?.transactionIdentifier
        : originalTransactionIdFromJson(details.verificationData.localVerificationData);
    final id = original ?? details.purchaseID;
    if (id == null || id.isEmpty) return null;
    return StorePurchase(platform: 'ios', purchaseId: id, subscriptionKey: 'ios:$id');
  }

  /// `originalTransactionId` from a StoreKit 2 transaction's JSON representation.
  static String? originalTransactionIdFromJson(String json) {
    try {
      final value = (jsonDecode(json) as Map<String, dynamic>)['originalTransactionId'];
      final id = value?.toString();
      return id == null || id.isEmpty ? null : id;
    } catch (_) {
      return null;
    }
  }
}

/// Talks to the purchase Cloud Functions. The server checks every purchase
/// with Apple, Google or Stripe and updates `subscriptions/{uid}`.
class PurchasesApi {
  static final PurchasesApi instance = PurchasesApi._();

  PurchasesApi._();

  /// Must match `setGlobalOptions({region})` in functions/src/index.ts.
  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  /// Sends a store purchase to the server for verification.
  Future<void> verifyPurchase(StorePurchase purchase) async {
    await _functions.httpsCallable('verifyPurchase').call({
      'platform': purchase.platform,
      'purchaseId': purchase.purchaseId,
    });
  }

  /// Stripe Checkout URL for the web. [plan] is 'monthly' or 'yearly'.
  Future<Uri> checkoutUrl(String plan) async {
    final result = await _functions.httpsCallable('createCheckoutSession').call({'plan': plan});
    return Uri.parse(result.data['url'] as String);
  }

  /// Prices of the web plans ('monthly', 'yearly') formatted for [languageCode];
  /// a plan is missing when Stripe isn't configured or can't be reached.
  Future<Map<String, String>> webPrices(String languageCode) async {
    final result = await _functions.httpsCallable('webPrices').call();
    final data = Map<String, dynamic>.from(result.data as Map);
    return {
      for (final plan in const ['monthly', 'yearly'])
        if (data[plan] is Map)
          plan: formatPrice(
            (data[plan]['amount'] as num).toInt(),
            data[plan]['currency'] as String,
            languageCode,
          ),
    };
  }

  /// [amount] in the currency's smallest unit (cents), e.g. "€ 4,99" in Dutch.
  static String formatPrice(int amount, String currency, String languageCode) {
    final format = NumberFormat.simpleCurrency(locale: languageCode, name: currency.toUpperCase());
    return format.format(amount / pow(10, format.decimalDigits ?? 2));
  }

  /// Stripe customer portal URL (change card, switch plan, cancel).
  Future<Uri> portalUrl() async {
    final result = await _functions.httpsCallable('createPortalSession').call();
    return Uri.parse(result.data['url'] as String);
  }

  /// The store ('apple', 'google', 'stripe') of an `already-subscribed:<source>`
  /// error from createCheckoutSession; null for other errors.
  static String? alreadySubscribedSource(String? message) {
    const prefix = 'already-subscribed:';
    if (message == null || !message.startsWith(prefix)) return null;
    return message.substring(prefix.length);
  }
}
