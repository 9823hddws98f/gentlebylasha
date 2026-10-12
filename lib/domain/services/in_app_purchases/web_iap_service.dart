import 'package:in_app_purchase/in_app_purchase.dart';

import '/domain/services/interfaces/in_app_purchases.dart';

class WebIapService implements InAppPurchases {
  WebIapService._();

  static final WebIapService instance = WebIapService._();

  // The web sells subscriptions through Stripe Checkout (see PurchasesApi),
  // not through a store, so store purchases are unavailable here.

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => Stream.empty();

  @override
  Future<bool> isAvailable() => Future.value(false);

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) =>
      Future.value(ProductDetailsResponse(
        productDetails: [],
        notFoundIDs: identifiers.toList(),
      ));

  @override
  Future<bool> buyNonConsumable(PurchaseParam purchaseParam) => Future.value(false);

  @override
  Future<void> completePurchase(PurchaseDetails purchaseDetails) => Future.value();

  @override
  Future<void> restorePurchases() => Future.value();
}
