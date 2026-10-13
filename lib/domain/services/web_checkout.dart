import 'package:flutter/foundation.dart';

import '/domain/cubits/entitlement_cubit.dart';
import '/helper/global_functions.dart';
import '/utils/browser_url/browser_url.dart';
import '/utils/get.dart';
import 'language_cubit.dart';

enum CheckoutResult { success, cancelled }

/// Stripe Checkout sends the user back to `<APP_URL>/?checkout=success|cancelled`
/// (createCheckoutSession in functions/src/purchases.ts).
CheckoutResult? checkoutResultFrom(Uri uri) => switch (uri.queryParameters['checkout']) {
      'success' => CheckoutResult.success,
      'cancelled' => CheckoutResult.cancelled,
      _ => null,
    };

/// [uri] without its query, keeping the path and the Flutter route (#/…).
String withoutQuery(Uri uri) => '${uri.path}${uri.hasFragment ? '#${uri.fragment}' : ''}';

/// On the web, after returning from Stripe Checkout: tells the user how it went
/// and refreshes premium. Removes the parameter so a reload doesn't repeat it.
Future<void> handleCheckoutReturn() async {
  if (!kIsWeb) return;
  final result = checkoutResultFrom(Uri.base);
  if (result == null) return;
  replaceBrowserUrl(withoutQuery(Uri.base));

  final tr = Get.the<LanguageCubit>().translation;
  switch (result) {
    case CheckoutResult.success:
      showToast(tr.checkoutSuccess);
      // Premium arrives through the Stripe webhook; listen again to pick it up.
      await Get.the<EntitlementCubit>().init();
    case CheckoutResult.cancelled:
      showToast(tr.checkoutCancelled);
  }
}
