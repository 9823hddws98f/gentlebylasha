import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

/// Google Play lists a subscription once per offer: its base plan, plus e.g. a
/// free-trial or intro-price offer (whose price is that of the first phase,
/// like "Free"). The paywall shows one regular price per plan and offers no
/// trials, so this keeps one entry per product id: the base plan (the offer
/// without an offer id), else the first one listed. App Store products are
/// listed once and pass through unchanged.
List<ProductDetails> onePerProduct(Iterable<ProductDetails> details) {
  final byId = <String, ProductDetails>{};
  for (final product in details) {
    final kept = byId[product.id];
    if (kept == null || (!_isBasePlan(kept) && _isBasePlan(product))) byId[product.id] = product;
  }
  return byId.values.toList();
}

bool _isBasePlan(ProductDetails product) {
  if (product is! GooglePlayProductDetails) return true;
  final index = product.subscriptionIndex;
  final offers = product.productDetails.subscriptionOfferDetails;
  if (index == null || offers == null || index >= offers.length) return true;
  return offers[index].offerId == null;
}

/// What buying [productId] on Google Play should do, given the purchases the
/// Play account already has ([owned], from queryPastPurchases):
/// - `restore`: it already has this plan. Buying it again fails; restoring
///   lets the server link it, or say it belongs to another Gentle account.
/// - `replace`: the other plan, bought for this Gentle account (or without an
///   account): the new plan replaces it, so the two don't run and bill side
///   by side. A plan of another Gentle account is left alone.
({bool restore, GooglePlayPurchaseDetails? replace}) playPurchasePlan(
  Iterable<PurchaseDetails> owned, {
  required String productId,
  required Iterable<String> planIds,
  required String? accountToken,
}) {
  final plans = owned
      .whereType<GooglePlayPurchaseDetails>()
      .where((p) =>
          planIds.contains(p.productID) &&
          p.billingClientPurchase.purchaseState == PurchaseStateWrapper.purchased)
      .toList();
  if (plans.any((p) => p.productID == productId)) return (restore: true, replace: null);
  final replace = plans.where((p) {
    final account = p.billingClientPurchase.obfuscatedAccountId;
    return account == null || account.isEmpty || account == accountToken;
  }).firstOrNull;
  return (restore: false, replace: replace);
}
